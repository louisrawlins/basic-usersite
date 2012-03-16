require 'uuidtools' # for SecureRandom

def random_password(size = 8)
  consonants = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk
                  nt ph pr rd sh sl sp st th tr)
  vowels = %w(a e i o u y)

  password = ""
  1.upto(size) do |i|
    group = [ vowels, consonants ][ i % 2 ]
    password << group[ SecureRandom.random_number(group.size) ]
  end

  password
end
