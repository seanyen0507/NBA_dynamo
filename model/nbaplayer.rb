require 'aws-sdk'


class Nbaplayer < AWS::Record::HashModel
  string_attr :description
  string_attr :playernames
  timestamps

  def self.destroy(id)
    find(id).delete
  end

  def self.delete_all
    all.each { |r| r.delete}
  end
end
