#
#  TkImg - format 'ico'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::ico', '1.3')
TkPackage.require('img::ico')

module Tk
  module Img
    module ICO
      def self.package_version
        begin
          TkPackage.require('img::ico')
        rescue
          ''
        end
      end
    end
  end
end
