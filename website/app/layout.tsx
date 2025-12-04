import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import '@/styles/globals.css'
import { ThemeProvider } from '@/components/theme-provider'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'GrabTube - Modern Tube Services Downloader',
  description: 'A cutting-edge multi-platform tube services downloader with modern UI/UX. Download videos from YouTube and 1000+ sites with ease.',
  keywords: ['youtube downloader', 'video downloader', 'tube services', 'grabtube', 'video converter'],
  authors: [{ name: 'Milos Vasic' }],
  openGraph: {
    title: 'GrabTube - Modern Tube Services Downloader',
    description: 'A cutting-edge multi-platform tube services downloader with modern UI/UX',
    url: 'https://milosvasic.github.io/GrabTube',
    siteName: 'GrabTube',
    images: [
      {
        url: '/logo.png',
        width: 1200,
        height: 630,
        alt: 'GrabTube Logo',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'GrabTube - Modern Tube Services Downloader',
    description: 'A cutting-edge multi-platform tube services downloader with modern UI/UX',
    images: ['/logo.png'],
  },
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}