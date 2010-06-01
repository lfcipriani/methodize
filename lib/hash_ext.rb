require 'lib/methodize'
class Hash
  def methodize
    self.extend(Methodize)
  end
end