class Object
  def try(property)
    send property if respond_to? property
  end
end
