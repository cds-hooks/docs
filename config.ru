`bundle exec middleman build`

use Rack::Static,
  :urls => ['/fonts', '/images', '/javascripts', '/stylesheets'],
  :root => 'build'

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('build/index.html', File::RDONLY)
  ]
}
