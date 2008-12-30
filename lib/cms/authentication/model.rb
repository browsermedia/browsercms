module Cms
  module Authentication
    module Model
      def self.included(model_class)
        model_class.extend ClassMethods
        model_class.class_eval do
          include InstanceMethods
        
          # Virtual attribute for the unencrypted password
          attr_accessor :password
          validates_presence_of     :password,                   :if => :password_required?
          validates_presence_of     :password_confirmation,      :if => :password_required?
          validates_confirmation_of :password,                   :if => :password_required?
          #validates_length_of       :password, :within => 6..40, :if => :password_required?
          before_save :encrypt_password
        end      
      end

      module ClassMethods
        def authenticate(login, password)
          u = find_by_login(login) # need to get the salt
          u && u.authenticated?(password) && !u.expired? ? u : nil
        end

        #Method to make it easy to change a user's password from the console, not used in the app
        def change_password(login, new_password)
          find_by_login(login).change_password(new_password)
        end

        def make_token
          secure_digest(Time.now, (1..10).map{ rand.to_s })
        end

        def password_digest(password, salt)
          key = '8771d0d9bef6f1091b723d2e701a17c811d69b26'
          digest = key
          10.times do
            digest = secure_digest(digest, salt, password, key)
          end
          digest
        end      
      
        def secure_digest(*args)
          Digest::SHA1.hexdigest(args.flatten.join('--'))
        end      
      
      end
    
      module InstanceMethods
        #Method to make it easy to change a user's password from the console, not used in the app
        def change_password(new_password)
          update_attributes(:password => new_password, :password_confirmation => new_password)
        end      
      
        # Encrypts the password with the user salt
        def encrypt(password)
          self.class.password_digest(password, salt)
        end
      
        def authenticated?(password)
          crypted_password == encrypt(password)
        end
      
        # before filter 
        def encrypt_password
          return if password.blank?
          self.salt = self.class.make_token if new_record?
          self.crypted_password = encrypt(password)
        end
      
        def password_required?
          crypted_password.blank? || !password.blank?
        end      
      
        def remember_token?
          (!remember_token.blank?) && 
            remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
        end

        # These create and unset the fields required for remembering users between browser closes
        def remember_me
          remember_me_for 2.weeks
        end

        def remember_me_for(time)
          remember_me_until time.from_now.utc
        end

        def remember_me_until(time)
          self.remember_token_expires_at = time
          self.remember_token            = self.class.make_token
          save
        end

        # refresh token (keeping same expires_at) if it exists
        def refresh_token
          if remember_token?
            self.remember_token = self.class.make_token 
            save      
          end
        end

        # 
        # Deletes the server-side record of the authentication token.  The
        # client-side (browser cookie) and server-side (this remember_token) must
        # always be deleted together.
        #
        def forget_me
          self.remember_token_expires_at = nil
          self.remember_token            = nil
          save
        end      
      end
    end
  end
end
