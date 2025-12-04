import React from 'react'
import { Play, Clock, FileText, CheckCircle } from 'lucide-react'

interface Lesson {
  id: string
  title: string
  duration: string
  description: string
  videoUrl?: string
  transcript?: string
  resources?: Array<{
    type: string
    title: string
    url: string
  }>
}

interface Module {
  id: string
  title: string
  description: string
  duration: string
  lessons: Lesson[]
}

interface VideoPlayerProps {
  module: Module
  lesson: Lesson
  onLessonComplete: (lessonId: string) => void
  completedLessons: string[]
}

export function VideoPlayer({ module, lesson, onLessonComplete, completedLessons }: VideoPlayerProps) {
  const [isPlaying, setIsPlaying] = React.useState(false)
  const [progress, setProgress] = React.useState(0)
  const [currentTime, setCurrentTime] = React.useState(0)
  const [duration, setDuration] = React.useState(0)
  const videoRef = React.useRef<HTMLVideoElement>(null)

  const handleTimeUpdate = () => {
    if (videoRef.current) {
      setCurrentTime(videoRef.current.currentTime)
      setDuration(videoRef.current.duration || 0)
      setProgress((videoRef.current.currentTime / (videoRef.current.duration || 1)) * 100)
    }
  }

  const handleEnded = () => {
    onLessonComplete(lesson.id)
    setIsPlaying(false)
  }

  const formatTime = (seconds: number) => {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = Math.floor(seconds % 60)
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
  }

  const isCompleted = completedLessons.includes(lesson.id)

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
      {/* Video Player */}
      <div className="relative aspect-video bg-black">
        {lesson.videoUrl ? (
          <video
            ref={videoRef}
            className="w-full h-full"
            onTimeUpdate={handleTimeUpdate}
            onEnded={handleEnded}
            onPlay={() => setIsPlaying(true)}
            onPause={() => setIsPlaying(false)}
            controls
          >
            <source src={lesson.videoUrl} type="video/mp4" />
            Your browser does not support the video tag.
          </video>
        ) : (
          <div className="flex items-center justify-center h-full">
            <div className="text-center">
              <Play className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-400">Video coming soon</p>
            </div>
          </div>
        )}

        {/* Progress Bar Overlay */}
        <div className="absolute bottom-0 left-0 right-0 h-1 bg-gray-800/50">
          <div 
            className="h-full bg-brand-red transition-all duration-300"
            style={{ width: `${progress}%` }}
          />
        </div>

        {/* Completion Badge */}
        {isCompleted && (
          <div className="absolute top-4 right-4 bg-green-500 text-white px-3 py-1 rounded-full flex items-center gap-2">
            <CheckCircle className="w-4 h-4" />
            <span className="text-sm font-medium">Completed</span>
          </div>
        )}
      </div>

      {/* Video Controls & Info */}
      <div className="p-6">
        <div className="flex items-start justify-between mb-4">
          <div className="flex-1">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
              {lesson.title}
            </h2>
            <p className="text-gray-600 dark:text-gray-300 mb-4">
              {lesson.description}
            </p>
            <div className="flex items-center gap-4 text-sm text-gray-500">
              <div className="flex items-center gap-1">
                <Clock className="w-4 h-4" />
                <span>{lesson.duration}</span>
              </div>
              {lesson.videoUrl && (
                <span>{formatTime(currentTime)} / {formatTime(duration)}</span>
              )}
            </div>
          </div>
        </div>

        {/* Lesson Actions */}
        <div className="flex gap-3 mb-6">
          {lesson.videoUrl && (
            <button
              onClick={() => videoRef.current?.play()}
              disabled={isPlaying}
              className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Play className="w-4 h-4 mr-2" />
              {isPlaying ? 'Playing' : 'Play'}
            </button>
          )}
          
          {lesson.transcript && (
            <button className="btn-outline">
              <FileText className="w-4 h-4 mr-2" />
              View Transcript
            </button>
          )}

          {!isCompleted && (
            <button
              onClick={() => onLessonComplete(lesson.id)}
              className="btn-secondary"
            >
              <CheckCircle className="w-4 h-4 mr-2" />
              Mark Complete
            </button>
          )}
        </div>

        {/* Resources */}
        {lesson.resources && lesson.resources.length > 0 && (
          <div className="border-t border-gray-200 dark:border-gray-700 pt-6">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Lesson Resources
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {lesson.resources.map((resource, index) => (
                <a
                  key={index}
                  href={resource.url}
                  target={resource.type === 'link' ? '_blank' : '_self'}
                  rel="noopener noreferrer"
                  className="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-700 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 transition-colors"
                >
                  <div className="w-8 h-8 bg-brand-red/10 rounded-lg flex items-center justify-center">
                    <FileText className="w-4 h-4 text-brand-red" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-gray-900 dark:text-white">
                      {resource.title}
                    </p>
                    <p className="text-sm text-gray-500 capitalize">
                      {resource.type}
                    </p>
                  </div>
                </a>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}