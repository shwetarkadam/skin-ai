import React, { useState, useEffect } from 'react';
import { Camera, Upload, Sparkles, Moon, Sun } from 'lucide-react';
import ImageUpload from './components/ImageUpload';
import Analysis from './components/Analysis';
import ExpertAdvice from './components/ExpertAdvice';

function App() {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [darkMode, setDarkMode] = useState(() => {
    return document.documentElement.classList.contains('dark');
  });

  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 dark:from-gray-900 dark:to-purple-900 transition-colors duration-200">
      <nav className="bg-white dark:bg-gray-800 shadow-sm sticky top-0 z-50 transition-colors duration-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Sparkles className="h-6 w-6 text-purple-600 dark:text-purple-400" />
              <span className="text-xl font-semibold text-gray-900 dark:text-white">SkinAI</span>
            </div>
            <div className="flex items-center space-x-4">
              <button
                onClick={toggleDarkMode}
                className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors duration-200"
                aria-label="Toggle dark mode"
              >
                {darkMode ? (
                  <Sun className="h-5 w-5 text-gray-600 dark:text-gray-300" />
                ) : (
                  <Moon className="h-5 w-5 text-gray-600 dark:text-gray-300" />
                )}
              </button>
              <button className="px-4 py-2 rounded-md text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700">
                For Experts
              </button>
              <button className="px-4 py-2 rounded-md text-sm font-medium bg-purple-600 text-white hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600">
                Sign In
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 md:py-12">
        {!selectedImage ? (
          <div className="text-center">
            <h1 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
              AI-Powered Skin Analysis
            </h1>
            <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
              Get personalized skincare recommendations backed by dermatologists
            </p>
            <div className="flex justify-center">
              <ImageUpload onImageSelect={setSelectedImage} />
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 md:gap-8">
            <Analysis image={selectedImage} />
            <ExpertAdvice />
          </div>
        )}
      </main>
    </div>
  );
}

export default App;