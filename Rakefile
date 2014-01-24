RB_GSL_VERSION = File.readlines('VERSION')[0].chomp

begin
  require 'hen'

  Hen.lay! {{
    :gem => {
      :name          => %q{rb-gsl},
      :version       => RB_GSL_VERSION,
      :summary       => %q{Ruby interface to the GNU Scientific Library [Ruby 2.x compatible fork]},
      :description   => %q{Ruby/GSL is a Ruby interface to the GNU Scientific Library, for numerical computing with Ruby},
      :authors       => ['Yoshiki Tsunesada', 'David MacMahon', 'Jens Wille'],
      :email         => %q{jens.wille@gmail.com},
      :license       => %q{GPL-2.0},
      :homepage      => :blackwinter,
      :dependencies  => [['narray', '>= 0.5.9']],
      :requirements  => ['GSL (http://www.gnu.org/software/gsl/)'],
      :require_paths => %w[lib lib/gsl lib/ool ext],

      :extra_files => FileList['examples/**/*', 'include/*', 'rdoc/*'].to_a,

      :extension => {
        :lib_dir => 'lib',
        :ext_dir => 'ext',
        :cross_compile => false
      },

      :required_ruby_version => '>= 1.8.1'
    },
    :rdoc => {
      :title      => 'Ruby/GSL{version: (v%s)}',
      :rdoc_files => FileList['rdoc/*'].to_a,
      :exclude    => %w[ext include lib],
      :main       => 'rdoc/index.rdoc'
    },
    :test => {
      :libs => %w[lib test]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
