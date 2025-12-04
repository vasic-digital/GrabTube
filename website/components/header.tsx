'use client'

import Link from 'next/link'
import { useState } from 'react'
import { Menu, X, Download, Github, Book, Play, Star } from 'lucide-react'
import { ThemeToggle } from '@/components/theme-toggle'

export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  const navigation = [
    { name: 'Features', href: '#features' },
    { name: 'Download', href: '#download' },
    { name: 'Documentation', href: '#documentation' },
    { name: 'Courses', href: '#courses' },
  ]

  return (
    <header className="fixed top-0 w-full bg-white/80 dark:bg-gray-900/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-700 z-50">
      <nav className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-brand-red rounded-lg flex items-center justify-center">
                <Download className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold text-gray-900 dark:text-white">
                GrabTube
              </span>
            </Link>
          </div>

          <div className="hidden md:block">
            <div className="ml-10 flex items-baseline space-x-4">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="text-gray-700 dark:text-gray-300 hover:text-brand-red dark:hover:text-red-400 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  {item.name}
                </Link>
              ))}
            </div>
          </div>

          <div className="hidden md:flex items-center space-x-4">
            <ThemeToggle />
            <Link
              href="https://github.com/milosvasic/GrabTube"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-700 dark:text-gray-300 hover:text-brand-red dark:hover:text-red-400 transition-colors"
            >
              <Github className="w-5 h-5" />
            </Link>
            <Link
              href="#download"
              className="btn-primary"
            >
              Download Now
            </Link>
          </div>

          <div className="md:hidden flex items-center space-x-2">
            <ThemeToggle />
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="text-gray-700 dark:text-gray-300 hover:text-brand-red dark:hover:text-red-400"
            >
              {isMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {isMenuOpen && (
          <div className="md:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="text-gray-700 dark:text-gray-300 hover:text-brand-red dark:hover:text-red-400 block px-3 py-2 rounded-md text-base font-medium"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
              <div className="pt-4 pb-3 border-t border-gray-200 dark:border-gray-700">
                <Link
                  href="https://github.com/milosvasic/GrabTube"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-primary w-full justify-center"
                >
                  Download Now
                </Link>
              </div>
            </div>
          </div>
        )}
      </nav>
    </header>
  )
}