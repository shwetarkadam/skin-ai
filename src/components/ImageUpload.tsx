import React, { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { Camera, Upload, X } from 'lucide-react';
import Webcam from 'react-webcam';

interface ImageUploadProps {
  onImageSelect: (image: string) => void;
}

const ImageUpload: React.FC<ImageUploadProps> = ({ onImageSelect }) => {
  const [showCamera, setShowCamera] = useState(false);
  const webcamRef = React.useRef<Webcam>(null);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    const reader = new FileReader();
    reader.onload = () => {
      onImageSelect(reader.result as string);
    };
    reader.readAsDataURL(file);
  }, [onImageSelect]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png']
    },
    multiple: false
  });

  const capturePhoto = useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot();
    if (imageSrc) {
      onImageSelect(imageSrc);
      setShowCamera(false);
    }
  }, [onImageSelect]);

  return (
    <div className="w-full max-w-3xl mx-auto">
      {showCamera ? (
        <div className="relative w-full">
          <button
            onClick={() => setShowCamera(false)}
            className="absolute top-2 right-2 z-10 p-2 bg-white dark:bg-gray-800 rounded-full shadow-lg"
          >
            <X className="w-6 h-6 text-gray-600 dark:text-gray-400" />
          </button>
          <Webcam
            ref={webcamRef}
            screenshotFormat="image/jpeg"
            className="w-full rounded-lg"
          />
          <button
            onClick={capturePhoto}
            className="absolute bottom-4 left-1/2 transform -translate-x-1/2 px-6 py-3 bg-purple-600 dark:bg-purple-500 text-white rounded-full shadow-lg hover:bg-purple-700 dark:hover:bg-purple-600 transition-colors"
          >
            Take Photo
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div
            {...getRootProps()}
            className="flex flex-col items-center justify-center p-6 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg hover:border-purple-500 dark:hover:border-purple-400 cursor-pointer transition-colors bg-white dark:bg-gray-800"
          >
            <input {...getInputProps()} />
            <Upload className="w-8 h-8 text-gray-400 dark:text-gray-500 mb-2" />
            <p className="text-sm text-center text-gray-600 dark:text-gray-400">
              {isDragActive
                ? "Drop your image here"
                : "Drag & drop an image or tap to select"}
            </p>
          </div>
          
          <button
            onClick={() => setShowCamera(true)}
            className="flex flex-col items-center justify-center p-6 border-2 border-gray-300 dark:border-gray-600 rounded-lg hover:border-purple-500 dark:hover:border-purple-400 cursor-pointer transition-colors bg-white dark:bg-gray-800"
          >
            <Camera className="w-8 h-8 text-gray-400 dark:text-gray-500 mb-2" />
            <p className="text-sm text-center text-gray-600 dark:text-gray-400">Take a photo</p>
          </button>
        </div>
      )}
    </div>
  );
};

export default ImageUpload;