require 'aws-sdk'


class Nbaplayer < AWS::Record::HashModel
  string_attr :description
  string_attr :playernames
  string_attr :count
  string_attr :result
  timestamps

  def self.destory(id)
    find(id).delete
  end

  def self.delete_all
    all.each { |r| r.delete}
  end
end
