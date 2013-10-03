require 'bio'
require 'net/http'

filename = ARGV[0]
specieslist = IO.readlines(ARGV[0])

# for each line species in specieslist
specieslist.each do |species|
    # args = join("+",species) "Manihot+esculenta"
    species.chomp!
    uri = URI.encode_www_form([["db", "taxonomy"], ["term", species]])
    tax_xml = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/esearch.fcgi?" + uri)
    puts tax_xml
    # parse tax_xml to get the taxid and then compose the next search
exit
    seq_xml = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/esearch.fcgi?db=nuccore&term=txid" + taxid + "[Organism]")
    # parse that to get a series of genbank records we need.

    # for each gid in that list, fetch the gb record:
    gb_rec = Net::HTTP.get("eutils.ncbi.nlm.nih.gov","/entrez/eutils/efetch.fcgi?db=nuccore&id="+gid+"&rettype=gb&retmode=text")

    gb = Bio::GenBank.new(str)
    gb.features.each do |feature|
        if feature.feature == 'source' then
            qs = feature.qualifiers
            qs.each do |q|
                puts q.qualifier + ":" + q.value.to_s
            end
        end
    end
end
