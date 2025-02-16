export type SkinType = 'oily' | 'dry' | 'combination' | 'normal';
export type SkinConcern = 'acne' | 'dryness' | 'oiliness' | 'sensitivity';

interface SkinRecommendation {
  skinType: SkinType;
  concerns: SkinConcern[];
  routine: {
    morning: string[];
    evening: string[];
  };
  products: {
    cleanser: string;
    treatment: string;
    moisturizer: string;
    sunscreen: string;
  };
  tips: string[];
}

export interface HuggingFaceAnalysis {
  label: string;
  score: number;
}

const skinRecommendations: Record<SkinType, SkinRecommendation> = {
  oily: {
    skinType: 'oily',
    concerns: ['acne', 'oiliness'],
    routine: {
      morning: [
        'Gentle foaming cleanser',
        'Oil-free moisturizer',
        'Lightweight sunscreen'
      ],
      evening: [
        'Double cleanse',
        'Salicylic acid treatment',
        'Oil-free night moisturizer'
      ]
    },
    products: {
      cleanser: 'Foaming cleanser with salicylic acid',
      treatment: 'Niacinamide serum',
      moisturizer: 'Oil-free gel moisturizer',
      sunscreen: 'Mattifying sunscreen SPF 50'
    },
    tips: [
      'Use oil-free products',
      'Don\'t skip moisturizer',
      'Consider using clay masks weekly',
      'Avoid heavy, comedogenic products'
    ]
  },
  dry: {
    skinType: 'dry',
    concerns: ['dryness', 'sensitivity'],
    routine: {
      morning: [
        'Gentle cream cleanser',
        'Hydrating serum',
        'Rich moisturizer',
        'Sunscreen'
      ],
      evening: [
        'Cream cleanser',
        'Hydrating treatment',
        'Rich night cream'
      ]
    },
    products: {
      cleanser: 'Creamy, non-foaming cleanser',
      treatment: 'Hyaluronic acid serum',
      moisturizer: 'Rich cream with ceramides',
      sunscreen: 'Hydrating sunscreen SPF 50'
    },
    tips: [
      'Avoid hot water when cleansing',
      'Layer hydrating products',
      'Use overnight masks',
      'Consider using facial oils'
    ]
  },
  combination: {
    skinType: 'combination',
    concerns: ['oiliness', 'dryness'],
    routine: {
      morning: [
        'Gentle balanced cleanser',
        'Zone-specific treatments',
        'Lightweight moisturizer',
        'Sunscreen'
      ],
      evening: [
        'Gentle cleanser',
        'Balanced treatment',
        'Zone-specific moisturizer'
      ]
    },
    products: {
      cleanser: 'Balanced pH cleanser',
      treatment: 'Dual-action serum',
      moisturizer: 'Lightweight lotion',
      sunscreen: 'Universal sunscreen SPF 50'
    },
    tips: [
      'Use different products for different zones',
      'Focus on balancing skin',
      'Consider multi-masking',
      'Adjust routine seasonally'
    ]
  },
  normal: {
    skinType: 'normal',
    concerns: ['maintenance'],
    routine: {
      morning: [
        'Gentle cleanser',
        'Antioxidant serum',
        'Light moisturizer',
        'Sunscreen'
      ],
      evening: [
        'Gentle cleanser',
        'Treatment product',
        'Night moisturizer'
      ]
    },
    products: {
      cleanser: 'Gentle pH-balanced cleanser',
      treatment: 'Vitamin C serum',
      moisturizer: 'Balanced moisturizer',
      sunscreen: 'Daily sunscreen SPF 50'
    },
    tips: [
      'Maintain consistent routine',
      'Focus on prevention',
      'Regular exfoliation',
      'Stay hydrated'
    ]
  }
};

export const analyzeSkinWithHuggingFace = async (imageData: string): Promise<HuggingFaceAnalysis[]> => {
  try {
    const response = await fetch('/api/analyze', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ image: imageData }),
    });

    if (!response.ok) {
      throw new Error('Failed to analyze image');
    }

    return await response.json();
  } catch (error) {
    console.error('Error analyzing image:', error);
    throw error;
  }
};

export const determineSkinType = (analysis: HuggingFaceAnalysis[]): SkinType => {
  // Map Hugging Face labels to skin types
  const labelToSkinType: Record<string, SkinType> = {
    'Acne': 'oily',
    'Dark Spots': 'combination',
    'Pimples': 'oily',
    'Healthy Skin': 'normal',
    'Blackheads': 'oily',
    'Wrinkles': 'dry'
  };

  // Find the label with the highest confidence score
  const topResult = analysis.reduce((prev, current) => 
    (current.score > prev.score) ? current : prev
  );

  return labelToSkinType[topResult.label] || 'normal';
};

export const getRecommendations = (skinType: SkinType): SkinRecommendation => {
  return skinRecommendations[skinType];
};