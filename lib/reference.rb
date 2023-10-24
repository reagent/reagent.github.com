# frozen_string_literal: true

class Reference
  def initialize(path:, initial:, password:)
    data_file = Pathname.new(path).join("#{initial}.yml.enc")
    decrypted = Decrypter.new(data_file, password).decrypt

    @vars = YAML.load(decrypted)
  end

  def name
    [@vars['first_name'], @vars['last_name']].join(' ')
  end

  def title
    @vars['title']
  end

  def company
    @vars['company']
  end

  def address
    [@vars['address_1'], @vars['address_2']].compact.join(', ')
  end

  def city
    @vars['city']
  end

  def state
    @vars['state']
  end

  def postal_code
    @vars['postal_code']
  end

  def email
    @vars['email']
  end

  def phone
    @vars['phone']
  end

  def out
    ERB.new(template).result(binding)
  end

  def template
    <<~EOF
      ## <%= name %>
      ### <%= title %>
      #### <%= company %>

      <%= address %>
      <%= city %>, <%= state %> <%= postal_code %>

      <%= email %>
      <%= phone %>
    EOF
  end
end
