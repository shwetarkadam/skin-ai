import React, { useEffect, useState } from 'react';
import { createWorker } from 'tesseract.js';
import { analyzeSkinWithHuggingFace, determineSkinType, getRecommendations, type SkinType, type HuggingFaceAnalysis } from '../utils/skinAnalysis';
import { Loader2, AlertCircle } from 'lucide-react';

interface AnalysisProps {
  image: string;
}

const Analysis: React.FC<AnalysisProps> = ({ image }) => {
  const [isAnalyzing, setIsAnalyzing] = useState(true);
  const [skinType, setSkinType] = useState<SkinType | null>(null);
  const [analysis, setAnalysis] = useState<HuggingFaceAnalysis[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const processImage = async () => {
      setIsAnalyzing(true);
      setError(null);
      
      try {
        const analysisResults = await analyzeSkinWithHuggingFace(image);
        setAnalysis(analysisResults);
        const detectedSkinType = determineSkinType(analysisResults);
        setSkinType(detectedSkinType);
      } catch (error) {
        console.error('Error processing image:', error);
        setError('Failed to analyze image. Please try again.');
      } finally {
        setIsAnalyzing(false);
      }
    };

    processImage();
  }, [image]);

  const recommendations = skinType ? getRecommendations(skinType) : null;

  return (
    <div className="w-full max-w-3xl mx-auto">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-4 md:p-6 space-y-6">
        <h2 className="text-xl md:text-2xl font-semibold text-gray-900 dark:text-white">Skin Analysis</h2>
        
        <div className="aspect-video relative rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700">
          <img
            src={image}
            alt="Uploaded skin"
            className="w-full h-full object-cover"
          />
        </div>

        <div className="space-y-4">
          {error && (
            <div className="p-4 bg-red-50 dark:bg-red-900/30 rounded-lg flex items-start space-x-2">
              <AlertCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
            </div>
          )}

          {isAnalyzing ? (
            <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
              <div className="flex items-center space-x-2">
                <Loader2 className="w-5 h-5 text-purple-600 dark:text-purple-400 animate-spin" />
                <h3 className="font-medium text-purple-800 dark:text-purple-200">Analyzing your skin...</h3>
              </div>
              <p className="text-sm text-purple-600 dark:text-purple-300 mt-1">
                Our AI is examining your skin conditions
              </p>
            </div>
          ) : (
            <>
              {analysis && (
                <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg space-y-2">
                  <h3 className="font-medium text-purple-800 dark:text-purple-200">AI Analysis Results</h3>
                  <div className="space-y-1">
                    {analysis.map((result, index) => (
                      <div key={index} className="flex justify-between text-sm">
                        <span className="text-purple-700 dark:text-purple-300">{result.label}</span>
                        <span className="text-purple-600 dark:text-purple-400">{(result.score * 100).toFixed(1)}%</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {skinType && (
                <div className="p-4 bg-green-50 dark:bg-green-900/30 rounded-lg">
                  <h3 className="font-medium text-green-800 dark:text-green-200">Analysis Complete</h3>
                  <p className="text-sm text-green-600 dark:text-green-300 mt-1">
                    Your skin type: <span className="font-semibold capitalize">{skinType}</span>
                  </p>
                </div>
              )}
              
              {recommendations && (
                <div className="space-y-6">
                  <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                    <h3 className="font-medium text-gray-900 dark:text-white mb-4">Daily Routine</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="bg-gray-50 dark:bg-gray-700/50 p-4 rounded-lg">
                        <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Morning</h4>
                        <ul className="space-y-2">
                          {recommendations.routine.morning.map((step, index) => (
                            <li key={index} className="text-sm text-gray-600 dark:text-gray-400 flex items-start">
                              <span className="font-medium mr-2">{index + 1}.</span>
                              <span>{step}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                      <div className="bg-gray-50 dark:bg-gray-700/50 p-4 rounded-lg">
                        <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Evening</h4>
                        <ul className="space-y-2">
                          {recommendations.routine.evening.map((step, index) => (
                            <li key={index} className="text-sm text-gray-600 dark:text-gray-400 flex items-start">
                              <span className="font-medium mr-2">{index + 1}.</span>
                              <span>{step}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </div>

                  <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                    <h3 className="font-medium text-gray-900 dark:text-white mb-4">Recommended Products</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      {Object.entries(recommendations.products).map(([type, product]) => (
                        <div key={type} className="bg-gray-50 dark:bg-gray-700/50 p-4 rounded-lg">
                          <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 capitalize mb-1">{type}</h4>
                          <p className="text-sm text-gray-600 dark:text-gray-400">{product}</p>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
                    <h3 className="font-medium text-gray-900 dark:text-white mb-4">Skincare Tips</h3>
                    <div className="bg-gray-50 dark:bg-gray-700/50 p-4 rounded-lg">
                      <ul className="space-y-2">
                        {recommendations.tips.map((tip, index) => (
                          <li key={index} className="text-sm text-gray-600 dark:text-gray-400 flex items-start">
                            <span className="mr-2">•</span>
                            <span>{tip}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default Analysis;