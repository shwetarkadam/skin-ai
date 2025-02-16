import React from 'react';
import { UserCheck } from 'lucide-react';

const ExpertAdvice: React.FC = () => {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
      <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-4">Expert Recommendations</h2>
      <div className="space-y-6">
        <div className="flex items-start space-x-4">
          <div className="flex-shrink-0">
            <img
              src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=100&h=100"
              alt="Dermatologist"
              className="w-12 h-12 rounded-full"
            />
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Dr. Sarah Johnson</h3>
              <UserCheck className="w-4 h-4 text-green-500" />
            </div>
            <p className="text-sm text-gray-600 dark:text-gray-400">Board Certified Dermatologist</p>
          </div>
        </div>

        <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
          <h3 className="font-medium text-gray-900 dark:text-white mb-2">Recommended Products:</h3>
          <div className="space-y-4">
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Recommendations will appear here after analysis is complete...
            </p>
          </div>
        </div>

        <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
          <h3 className="font-medium text-gray-900 dark:text-white mb-2">Treatment Plan:</h3>
          <div className="space-y-4">
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Personalized treatment plan will be generated based on your skin analysis...
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExpertAdvice;