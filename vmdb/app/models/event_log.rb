class EventLog < ActiveRecord::Base
  belongs_to :operating_system

  include ReportableMixin

  def self.add_elements(parent, xmlNode)
    add_missing_elements(parent, xmlNode)
  end

  def self.add_missing_elements(parent, xmlNode)
    hashes = xml_to_hashes(xmlNode)
    return if hashes.nil?

    os = parent.operating_system
    EmsRefresh.save_event_logs_inventory(os, hashes)
  end

  def self.xml_to_hashes(xmlNode)
    return xmlNode if xmlNode.kind_of?(Array) && xmlNode[0].kind_of?(Hash)
    return nil unless MiqXml.isXmlElement?(xmlNode)

    result = []
    name = ""
    xmlNode.each_element('event_log') do |el|
      el.each_recursive do |e|
        if e.name == "log"
          name = e.attributes[:name]
        else
          nh = e.attributes.to_h
          nh[:name] = name
          result << nh
        end
      end
    end

    return result
  end
end
