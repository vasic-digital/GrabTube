/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  basePath: process.env.NODE_ENV === 'production' ? '/grabtube' : '',
  assetPrefix: process.env.NODE_ENV === 'production' ? '/grabtube' : '',
  env: {
    NEXT_PUBLIC_GITHUB_URL: 'https://github.com/milosvasic/GrabTube',
    NEXT_PUBLIC_DOWNLOAD_URL: 'https://github.com/milosvasic/GrabTube/releases',
  },
}

module.exports = nextConfig