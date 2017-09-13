# `mkdocs build`

# use Rack::Static,
#   :urls => ['/catalog', '/community', '/css', '/fonts', '/images', '/img', '/js', '/mkdocs', '/spec'],
#   :root => 'site'

# run lambda { |env|
#   [
#     200,
#     {
#       'Content-Type'  => 'text/html',
#       'Cache-Control' => 'public, max-age=86400'
#     },
#     File.open('site/index.html', File::RDONLY)
#   ]
# }