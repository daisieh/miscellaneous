require 'bio'
require 'net/http'
require 'nokogiri'
require 'json'

filename = ARGV[0]
specieslist = IO.readlines(ARGV[0])

specieshash = {}
# for each line species in specieslist
i = 1
specieslist.each do |species|
    species.chomp!
    uri = URI.encode_www_form([["db", "taxonomy"], ["term", species]])
    tax_xml = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/esearch.fcgi?" + uri)
    taxids = []

    # parse tax_xml to get the taxid and then compose the next search
    Nokogiri.XML(tax_xml).xpath('/eSearchResult/IdList/Id').each do |taxid|
        taxdata = {}
        taxdata['taxon_id'] = taxid.inner_text
        uri = URI.encode_www_form([["db", "nuccore"], ["term", "txid"+taxid.inner_text+"[Organism]"], ["retmax", 3.to_s]])
        seq_xml = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/esearch.fcgi?" + uri)
        Nokogiri.XML(seq_xml).xpath('/eSearchResult/IdList/Id').each do |seqid|
            sequence = {}
            seqid = seqid.inner_text
            gb_rec = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/efetch.fcgi?db=nuccore&id="+seqid+"&rettype=gb&retmode=text")
            gb = Bio::GenBank.new(gb_rec)
            if (gb.seq.to_s.length > 0) then
                sequence['sequence'] = gb.seq
                gb.features.each do |feature|
                    if feature.feature == 'source' then
                        sequence['source'] = {}
                        qs = feature.qualifiers
                        qs.each do |q|
                            sequence['source'][q.qualifier] = q.value
                        end
                    end
                end
                taxdata[seqid] = sequence
            end
        end
        taxids.push(taxdata)
    end
    specieshash [species] = taxids
end

puts JSON.generate(specieshash)

