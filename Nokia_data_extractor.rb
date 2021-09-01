require 'net/sftp'
require 'zip'
require 'nokogiri'
require 'Set'
require 'csv'

#download file
Net::SFTP.start('ipaddr', 'user', :password => 'password') do |sftp|
sftp.download!("/Nokia/13_Atyrau_N.xml.zip", "\13_Atyrau_N.xml.zip")
end

#unzip xml file
def extract_zip(file, destination)
    FileUtils.mkdir_p(destination)
  
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        fpath = File.join(destination, f.name)
        zip_file.extract(f, fpath) unless File.exist?(fpath)
      end
    end
  end


extract_zip("\130601_Atyrau_N.xml.zip", ".") 
#read extracted data
xml = File.read("130601_Atyrau_N-2020-07-14.xml")
doc = Nokogiri::XML(xml)

#use empty array for data we want to collect
all_things = []
doc.xpath('//*[@class="BCF"]').each do |file| #each tag with attribute class="BCF"
    distname = file.xpath(".").attr('distName')
    pname = file.xpath('./*[@name="name"]').text
    sbts = file.xpath('./*[@name="SBTSId"]').text
    mplane = file.xpath('./*[@name="btsMPlaneIpAddress"]').text
    all_things << [distname, pname, sbts, mplane]
end

#puts all_things
#writing data to a csv file
CSV.open('xmloutput.csv', 'wb' ) do |row|
  #row names
  row << ['distname', 'name', 'SBTSID', 'MplaneIpAdress']
  all_things.each do |data|
    #write to the rows
    row << data
  end
end
#upload file
Net::SFTP.start('ipaddr', 'user', :password => 'password') do |sftp|
sftp.upload!("xmloutput.csv", "/Nokia/xmloutput.csv")
end