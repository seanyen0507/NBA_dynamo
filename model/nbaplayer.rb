require 'aws-sdk'


class Nbaplayer < AWS::Record::HashMode
  string_attr :description
  string_attr :playernames
  timestamps

  def self.destory(id)
    find(id).delete
  end

  def self.delete_all
    all.each { |r| r.delete}
  end
end
