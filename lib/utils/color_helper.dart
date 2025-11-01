class ColorHelper {
  // Comprehensive color mapping
  static final Map<String, String> _colorMap = {
    // Basic Colors
    '#ff0000': 'Red', '#00ff00': 'Green', '#0000ff': 'Blue',
    '#ffff00': 'Yellow', '#ff00ff': 'Magenta', '#00ffff': 'Cyan',
    '#ffffff': 'White', '#000000': 'Black',

    // Grays
    '#808080': 'Gray', '#c0c0c0': 'Silver', '#696969': 'Dim Gray',
    '#a9a9a9': 'Dark Gray', '#d3d3d3': 'Light Gray',

    // Blues
    '#000080': 'Navy', '#4169e1': 'Royal Blue', '#1e90ff': 'Dodger Blue',
    '#87ceeb': 'Sky Blue', '#4682b4': 'Steel Blue', '#5f9ea0': 'Cadet Blue',
    '#b0c4de': 'Light Steel Blue', '#4a90e2': 'Blue', '#3e49e0': 'Blue',
    '#0066cc': 'Blue', '#003366': 'Dark Blue', '#6699cc': 'Light Blue',

    // Reds
    '#dc143c': 'Crimson', '#b22222': 'Fire Brick', '#ff6347': 'Tomato',
    '#ff4500': 'Orange Red', '#cd5c5c': 'Indian Red', '#a0522d': 'Sienna',

    // Greens
    '#008000': 'Green', '#32cd32': 'Lime Green', '#90ee90': 'Light Green',
    '#98fb98': 'Pale Green',
    '#00ff7f': 'Spring Green',
    '#00fa9a': 'Medium Spring Green',
    '#228b22': 'Forest Green',
    '#006400': 'Dark Green',
    '#556b2f': 'Dark Olive Green',
    '#6b8e23': 'Olive Drab',

    // Yellows/Oranges
    '#ffa500': 'Orange', '#ff8c00': 'Dark Orange', '#ffd700': 'Gold',
    '#ffffe0': 'Light Yellow', '#fffacd': 'Lemon Chiffon', '#f0e68c': 'Khaki',
    '#bdb76b': 'Dark Khaki', '#daa520': 'Goldenrod', '#cd853f': 'Peru',

    // Purples
    '#800080': 'Purple', '#9932cc': 'Dark Orchid', '#ba55d3': 'Medium Orchid',
    '#da70d6': 'Orchid', '#ee82ee': 'Violet', '#dda0dd': 'Plum',
    '#9370db': 'Medium Purple',
    '#8a2be2': 'Blue Violet',
    '#9400d3': 'Dark Violet',
    '#4b0082': 'Indigo',

    // Browns
    '#a52a2a': 'Brown', '#8b4513': 'Saddle Brown', '#d2691e': 'Chocolate',
    '#f4a460': 'Sandy Brown', '#deb887': 'Burlywood', '#d2b48c': 'Tan',
    '#bc8f8f': 'Rosy Brown', '#8b7d6b': 'Dark Goldenrod',

    // Pinks
    '#ffc0cb': 'Pink', '#ffb6c1': 'Light Pink', '#ff69b4': 'Hot Pink',
    '#ff1493': 'Deep Pink',
    '#c71585': 'Medium Violet Red',
    '#db7093': 'Pale Violet Red',

    // Additional common colors
    '#2f4f4f': 'Dark Slate Gray',
    '#708090': 'Slate Gray',
    '#778899': 'Light Slate Gray',
    '#20b2aa': 'Light Sea Green',
    '#008b8b': 'Dark Cyan',
    '#00ced1': 'Dark Turquoise',
    '#40e0d0': 'Turquoise',
    '#48d1cc': 'Medium Turquoise',
    '#afeeee': 'Pale Turquoise',
    '#7fffd4': 'Aquamarine', '#66cdaa': 'Medium Aquamarine',
    '#ffe4b5': 'Moccasin', '#ffe4c4': 'Bisque', '#ffefd5': 'Papaya Whip',
    '#faf0e6': 'Linen', '#fdf5e6': 'Old Lace',
    '#f0fff0': 'Honeydew', '#f5fffa': 'Mint Cream', '#f0ffff': 'Azure',
    '#f0f8ff': 'Alice Blue', '#e6e6fa': 'Lavender', '#fff0f5': 'Lavender Blush',
    '#ffdead': 'Navajo White',
    '#ffdab9': 'Peach Puff',
    '#ffa07a': 'Light Salmon',
    '#fa8072': 'Salmon', '#e9967a': 'Dark Salmon', '#f08080': 'Light Coral',
    '#8b0000': 'Dark Red', '#800000': 'Maroon',
  };

  /// Convert hex color to readable name
  ///
  /// This method first tries to find an exact match in the predefined color map.
  /// If no exact match is found, it analyzes the RGB values to determine the color family.
  ///
  /// Examples:
  /// - '#ff0000' → 'Red'
  /// - '#4a90e2' → 'Blue'
  /// - '#a1b2c3' → 'Bluish' (dynamic detection)
  /// - '#xyz123' → '#xyz123' (fallback for invalid hex)
  static String getColorName(String hexColor) {
    // First try exact match
    String normalizedHex = hexColor.toLowerCase().trim();
    if (_colorMap.containsKey(normalizedHex)) {
      return _colorMap[normalizedHex]!;
    }

    // If no exact match, try to detect color family based on RGB values
    try {
      // Remove # if present
      if (normalizedHex.startsWith('#')) {
        normalizedHex = normalizedHex.substring(1);
      }

      // Convert hex to RGB
      int r = int.parse(normalizedHex.substring(0, 2), radix: 16);
      int g = int.parse(normalizedHex.substring(2, 4), radix: 16);
      int b = int.parse(normalizedHex.substring(4, 6), radix: 16);

      // Detect color family based on RGB values
      return _detectColorFamily(r, g, b);
    } catch (e) {
      // If parsing fails, return original hex
      return hexColor;
    }
  }

  /// Detect color family based on RGB values
  ///
  /// This method analyzes the RGB values to determine the dominant color family.
  /// It uses thresholds to classify colors into meaningful categories.
  static String _detectColorFamily(int r, int g, int b) {
    // Calculate dominant color
    if (r > g && r > b) {
      if (r > 200 && g < 100 && b < 100) return 'Red';
      if (r > 150 && g > 100 && b < 100) return 'Orange';
      if (r > 150 && g > 150 && b < 100) return 'Yellow';
      return 'Reddish';
    } else if (g > r && g > b) {
      if (g > 200 && r < 100 && b < 100) return 'Green';
      if (g > 150 && r > 100 && b < 100) return 'Yellow';
      if (g > 150 && r < 100 && b > 100) return 'Cyan';
      return 'Greenish';
    } else if (b > r && b > g) {
      if (b > 200 && r < 100 && g < 100) return 'Blue';
      if (b > 150 && r > 100 && g < 100) return 'Purple';
      if (b > 150 && r < 100 && g > 100) return 'Cyan';
      return 'Bluish';
    } else if (r > 200 && g > 200 && b > 200) {
      return 'Light';
    } else if (r < 50 && g < 50 && b < 50) {
      return 'Dark';
    } else if (r > 100 && g > 100 && b > 100) {
      return 'Gray';
    }

    return 'Mixed';
  }

  /// Get all available color names
  ///
  /// Returns a list of all predefined color names in the color map.
  static List<String> getAllColorNames() {
    return _colorMap.values.toSet().toList()..sort();
  }

  /// Get all available hex codes
  ///
  /// Returns a list of all predefined hex codes in the color map.
  static List<String> getAllHexCodes() {
    return _colorMap.keys.toList()..sort();
  }

  /// Check if a hex color is predefined
  ///
  /// Returns true if the hex color exists in the predefined color map.
  static bool isPredefinedColor(String hexColor) {
    return _colorMap.containsKey(hexColor.toLowerCase().trim());
  }

  /// Get color count
  ///
  /// Returns the total number of predefined colors in the color map.
  static int getColorCount() {
    return _colorMap.length;
  }
}
