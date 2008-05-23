require 'people_csv_reader'
require 'people_xml_writer'
require 'people_image_downloader'

class People < Array
  
  def initialize
    @all_periods = []
  end
  
  # Override method to populate @all_house_periods
  def <<(person)
    @all_periods.concat(person.periods)
    super
  end
  
  # Methods that return Person object
  
  # Returns nil if non found. Throws exception if more than one match
  def find_person_by_name(name)
    matches = find_people_by_name(name)
    throw "More than one match for name #{name.full_name} found" if matches.size > 1
    matches[0] if matches.size == 1
  end
  
  def find_person_by_name_current_on_date(name, date)
    matches = find_people_by_name_current_on_date(name, date)
    throw "More than one match for name #{name.full_name} found" if matches.size > 1
    matches[0] if matches.size == 1
  end
  
  # Returns all the people that match a particular name and have current senate/house of representatives positions on the date
  def find_people_by_name_current_on_date(name, date)
    find_people_by_name(name).find_all {|p| p.current_position_on_date?(date)} 
  end
  
  def find_people_by_name(name)
    find_all{|p| name.matches?(p.name)}
  end    
  
  # Methods that return Period objects
  
  def house_speaker(date)
    member = find_house_members_current_on(date).find {|m| m.house_speaker?}
    throw "Could not find house speaker for date #{date}" if member.nil?
    member
  end
  
  def deputy_house_speaker(date)
    member = find_house_members_current_on(date).find {|m| m.deputy_house_speaker?}
    throw "Could not find deputy house speaker for date #{date}" if member.nil?
    member
  end

  def find_member_by_name_current_on_date(name, date)
    matches = find_members_by_name_current_on_date(name, date)
    throw "More than one match for name #{name.full_name} found" if matches.size > 1
    matches[0] if matches.size == 1
  end
  
  def find_members_by_name_current_on_date(name, date)
    find_house_members_current_on(date).find_all {|m| name.matches?(m.person.name)}
  end
  
  # Returns the house members that are currently members of the House of Representatives
  def find_current_house_members
    all_house_periods.find_all {|m| m.current?}
  end
  
  # Returns the house members that are members on the given date
  def find_house_members_current_on(date)
    all_house_periods.find_all {|m| m.current_on_date?(date)}
  end
  
  def find_house_period_by_id(id)
    all_house_periods.find{|p| p.id == id}
  end
  
  # End of methods that return Period objects
  
  # Facade for readers and writers
  def People.read_members_csv(filename)
    PeopleCSVReader.read_members(filename)
  end
  
  def read_ministers_csv(filename)
    PeopleCSVReader.read_ministers(filename, self)
  end
    
  def write_xml(people_filename, members_filename, ministers_filename)
    PeopleXMLWriter.write(self, people_filename, members_filename, ministers_filename)
  end
  
  def download_images(small_image_dir, large_image_dir)
    downloader = PeopleImageDownloader.new
    downloader.download(self, small_image_dir, large_image_dir)
  end
  
  private
  
  def all_house_periods
    @all_periods.find_all{|p| p.house == "representatives"}
  end
end
