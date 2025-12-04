'use client'

import { useState } from 'react'
import { Check, Download, Play, Shield, Zap, Globe, Smartphone, Monitor, Tv } from 'lucide-react'
import { Button } from '@/components/ui/button'

export function Hero() {
  const [activePlatform, setActivePlatform] = useState('windows')

  const platforms = [
    { id: 'windows', name: 'Windows', icon: Monitor, color: 'bg-blue-500' },
    { id: 'macos', name: 'macOS', icon: Monitor, color: 'bg-gray-600' },
    { id: 'linux', name: 'Linux', icon: Monitor, color: 'bg-orange-500' },
    { id: 'android', name: 'Android', icon: Smartphone, color: 'bg-green-500' },
    { id: 'ios', name: 'iOS', icon: Smartphone, color: 'bg-black' },
  ]

  const features = [
    { icon: Zap, title: 'Lightning Fast', description: 'Multi-threaded downloads for maximum speed' },
    { icon: Shield, title: 'Safe & Secure', description: 'Open source, ad-free, and privacy-focused' },
    { icon: Globe, title: '1000+ Sites', description: 'Support for YouTube, Vimeo, TikTok, and more' },
    { icon: Play, title: 'All Formats', description: 'MP4, MP3, AVI, and any format you need' },
  ]

  return (
    <section className="relative min-h-screen flex items-center justify-center bg-gradient-to-br from-brand-red/10 via-white to-brand-dark/10 dark:from-brand-red/20 dark:via-gray-900 dark:to-brand-dark/20">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 pt-20">
        <div className="text-center">
          <div className="inline-flex items-center justify-center p-2 bg-brand-red/10 rounded-full mb-8">
            <span className="text-brand-red text-sm font-semibold">✨ Now with 80%+ test coverage</span>
          </div>
          
          <h1 className="text-5xl md:text-7xl font-bold text-gray-900 dark:text-white mb-6">
            <span className="bg-gradient-to-r from-brand-red to-red-500 bg-clip-text text-transparent">
              GrabTube
            </span>
            <br />
            Modern Tube Downloader
          </h1>
          
          <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-12 max-w-3xl mx-auto">
            Download videos from YouTube and 1000+ sites with our cutting-edge multi-platform downloader. 
            Enjoy lightning-fast downloads, playlist support, and a modern, intuitive interface.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Button size="lg" className="btn-primary text-lg px-8 py-4 h-auto">
              <Download className="w-5 h-5 mr-2" />
              Download for Free
            </Button>
            <Button size="lg" variant="outline" className="text-lg px-8 py-4 h-auto border-2">
              <Play className="w-5 h-5 mr-2" />
              Watch Demo
            </Button>
          </div>

          <div className="max-w-4xl mx-auto">
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-xl p-6">
              <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-white">
                Select Your Platform
              </h3>
              <div className="grid grid-cols-2 sm:grid-cols-5 gap-4 mb-6">
                {platforms.map((platform) => (
                  <button
                    key={platform.id}
                    onClick={() => setActivePlatform(platform.id)}
                    className={`p-4 rounded-lg border-2 transition-all ${
                      activePlatform === platform.id
                        ? 'border-brand-red bg-brand-red/10'
                        : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                    }`}
                  >
                    <div className={`w-8 h-8 ${platform.color} rounded-lg flex items-center justify-center mb-2 mx-auto`}>
                      <platform.icon className="w-5 h-5 text-white" />
                    </div>
                    <span className="text-sm font-medium text-gray-900 dark:text-white">
                      {platform.name}
                    </span>
                  </button>
                ))}
              </div>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                {features.map((feature) => (
                  <div key={feature.title} className="text-center">
                    <div className="w-12 h-12 bg-brand-red/10 rounded-lg flex items-center justify-center mb-3 mx-auto">
                      <feature.icon className="w-6 h-6 text-brand-red" />
                    </div>
                    <h4 className="font-semibold text-gray-900 dark:text-white mb-1">
                      {feature.title}
                    </h4>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {feature.description}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce-gentle">
        <div className="w-6 h-10 border-2 border-gray-300 rounded-full flex justify-center">
          <div className="w-1 h-3 bg-gray-300 rounded-full mt-2"></div>
        </div>
      </div>
    </section>
  )
}