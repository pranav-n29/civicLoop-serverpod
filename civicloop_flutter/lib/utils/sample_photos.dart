import 'dart:convert';
import 'dart:typed_data';

/// Represents a pre-packaged civic demo photo for quick testing and presentations.
class SamplePhoto {
  final String id;
  final String name;
  final String fileName;
  final String description;
  final String base64Png;

  const SamplePhoto({
    required this.id,
    required this.name,
    required this.fileName,
    required this.description,
    required this.base64Png,
  });

  Uint8List get bytes => base64Decode(base64Png);

  ByteData get byteData {
    final raw = bytes;
    return raw.buffer.asByteData(raw.offsetInBytes, raw.lengthInBytes);
  }
}

/// Utility for photo validation and sample assets.
class PhotoUtils {
  /// Allowed image file extensions for CivicLoop issue photos.
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  /// Maximum allowed photo upload size in bytes (5 MB).
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  /// Validates [fileName] extension.
  static String? validateExtension(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'Filename cannot be empty.';
    }
    final lastDot = trimmed.lastIndexOf('.');
    if (lastDot == -1 || lastDot == trimmed.length - 1) {
      return 'Filename must include an extension (.jpg, .png, .webp).';
    }
    final ext = trimmed.substring(lastDot + 1).toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      return 'Invalid photo format ".$ext". Allowed: ${allowedExtensions.join(', ')}.';
    }
    return null;
  }

  /// Validates [bytes] size and content.
  static String? validateBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      return 'Photo file is empty.';
    }
    if (bytes.lengthInBytes > maxPhotoBytes) {
      final mb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'Photo size ($mb MB) exceeds maximum allowed limit of 5 MB.';
    }
    return null;
  }

  /// Converts [Uint8List] bytes to [ByteData].
  static ByteData toByteData(Uint8List bytes) {
    return bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  /// Formats byte size into human readable string.
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Built-in sample photos for 1-click hackathon demo submissions.
  /// Valid PNG images representing common civic issues.
  static const List<SamplePhoto> samplePhotos = [
    SamplePhoto(
      id: 'pothole',
      name: 'Pothole on Main St',
      fileName: 'pothole_evidence.png',
      description: 'Deep road crater causing tire and suspension damage',
      // Valid 64x64 PNG: asphalt background with dark roadway crater and cracked asphalt
      base64Png:
          'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACx'
          'jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAARpSURBVHhe7Zppc9MwEIb5AdCLtDmbsyFp2lJI'
          'L5reHAMD///3iHncUSazkmL5EmacD88XxbZ2311rtXLevHz/o6rMGzlQNTYCyIGqsRFADlSNjQBy'
          'oGpsBJADVWMjgByoGhsB5EDV+CcCPL78VLd3LwYPTz+Na4umcAGevv5S17eP6uz8Uo0+zFS3fxTL'
          'cHysTj5eqKsvD5FY8pl5UpgAN4tnNZ2dG86lYTw9jcSQc+RB7gLMr+6iCEon8mAwmqpPF7fq+dtv'
          'Y9605CbA/eOPKFLS6CLgVVrcfzNsSEMuAhCV3mBsGFo055+vM2dDZgFYrKRhcbQP+6rZ7hm0On3j'
          '2jhYZ7KIkEkAX+c73aE6qLfU7t6+evduW719u+WE33d3a2r/oKk63YHxLBtJReBaXV1SC0BZk4ZI'
          'Wp2e2nu/bziZhN29mmq2usazJYggbZQs7r+qyfRU1estNTt5vd5LgFXFgBInDViFiL+v1Q1nsoAQ'
          'cRlBBbLZ/nl+o7q9garVDpaMJ7N4AbiZSDcabTU9PovG2NhQjuTkGt7juDRPC89dlw0sxHo3uRpt'
          '7TR+EHkqlvbRKsCq4/pmFOS3damPcUU5v0qj2Tbm1gyPjo1o9wdjNb+8Nfw0BLA53jnsq4urxTL6'
          'rnLHyh7CeQ1VQ9rwGoRDZ7RtLAXgPXE5vrzmcmFMCIe9kdre3jOMLJKtrZ1orbHZ8mFyYjjqYikA'
          'kXc5rjmanBgTAiVOGhiC2n7DsAVYo3zL4lIAbnA5DqS/nEizsxM2+hqygIhLe+Du4bvhgw3rImiD'
          'B8pJgHdfGhYSV1WgBZc+2PAWgAfKSQADpFEhqTfsFYH1Svpgw1sANhlyEsAAaVRI2DJLm+B8fmP4'
          'YMNbAA4k5CRA2ZFGhYQFWNoEdKjSBxveAtB/y0mAnZ80KiQEQNoEvidI3gLQC8hJgFWY1VgaFgI2'
          'Xra9APgemHgLAK4egHosjQsBnaa0BditUral/TYSCcAJjJwMiELIbTAwn+sAZXY6N2x3kUgA9tVy'
          'Mk3oxdC1+AHturTdRSIBYHL80ZhQE+pV4KxBzq3hwFTavI7EArAjdHWEUHRf4Nr/a/jCJG1eR2IB'
          'gE2GnHgVdod5d4dUmkbTXvI0NHTS1jhSCUDjFPcNgPJINmQtkSx2RN3V9Gj4GOPbAa6SSgCgzLja'
          'YwmR8zkRXoWTYU5+4hwHnE/7YTW1AJBEBA2li/6BPbyEjOEkWd6zjizOQyYBABHy+giaFF7DLM5D'
          'ZgE0l9cPqj+cGEYWAVXIt9mJIzcBgH6BXZg0OE/ItriDziTkKoCGtKQkrdsvuGh3+tYOj89wvsdc'
          'SShEAA3rA68Gxvv8O4QvP8uz/OE4yiYOYor8l0ihAkj0f4Po1dlMSaJ1ZDCKBBiOJsb9RRBUAB8Q'
          'SGdB0m1tGkonABD9UFlQSgFCZkEpBYBQWVBaAUJlQWkFgBBZUGoBQmRBqQWAorOg9AIUnQWlFwCIPv'
          'C/H/lbVv4LAYpkI4AcqBp/ATAxLUQhWbAxAAAAAElFTkSuQmCC',
    ),
    SamplePhoto(
      id: 'streetlight',
      name: 'Flickering Streetlight',
      fileName: 'streetlight_evidence.png',
      description: 'Public lamp post dark at night on pedestrian crossing',
      // Valid 64x64 PNG: dark night sky with warm glowing streetlight lantern
      base64Png:
          'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACx'
          'jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAOlSURBVHhe7Znfa85RHMf3H7iSuKBkz4+FWlk9'
          'RVasqGU3i9VqF8skMRkriqitrEaKtPKjReECF0ooibSUtRuthLgRF1rIjQslR++nvnq8z/k+zzmf'
          'c75f6jkXr5463+08n8/r+zk/n5ZFS9pUM9PCDc1GFMANzUYUwA3NRhTADc1GFMANzcY/E7Cuvawq'
          'HX/Df5MHuQlAwsP9RXX1REHdO9OayvWxgjo4UFSbN+QjJHMB27pKDZNO49ZEqxroKanFy/R+Q5GZ'
          'gI2Vsrp0VJY4g6rY2plNRWQiYGdvSUsiBBgaoashqICly9vU2J6iFnhIzh4qVr+Hv1tKUAFZJ58A'
          'CaEqIZiA3TvyST7h2K6iFoOEIAIw4XGAedC7paTF4oq3AJRiqNneFSyTK1b6rQ7eAvq65TP+zJWK'
          'en6js/rJz2zB5opjcsFLAN4+1mgOqh5PpzvUp/m96te3SY2Fl8Pq2bX12v/U486kXxV4CXAd+y/u'
          'dqufXya0xJl3M/3qwTn7ykIVcmy2eAnAxoSDSWP+fo+WaD3ezw5qfaRx+oB8GHgJsC1/lL3Nm2cw'
          'P3BfJjAMpJsjsYBVBfvy//x6REvOhu8fj2t9pSE9TosF4HjLQZjAWObEXHh8sV3r04T0sCQWgPM6'
          'B2ECszon5cLc7S6tTxPSiVAsALswDsKE6+THvHnSp/VpAidQjtEGsQCUHAdhYvbmJi0pF7B0cp8m'
          'cHHCMdogFoBJh4Mw8fD8ai0pF2x3ibh54hhtEAtwWQUwm3NiNmDp5L7SyH0VwDYY6y8HYkI6DF49'
          '2q71lQZeCMdog1gAwJmcA0njw9yQlmA9vr4d1fpIY+pIQYvNFi8BGHccTBqYC3DY4URNIHnb9R/g'
          'MoZjs8VLALaftsMgAbP6j4VxLWmAMe9S9gnS8Q+8BACcxzkgG7DPvzy1X01fGKl+2u77mZP75G8f'
          'eAvAWdy1ChKGRk/9gZ/ZsnaN/O0DbwFAeivkKwDHcY7FlSACAEqRA2yEjwDM/CGuxoMJwIToejkq'
          'FYB7COm6zwQTAMrlstMPoRIBuAn2Hfe1BBUAUAm4ouLATbgKQNmHevMJwQUkYHPSaHVwEXB4MNzP'
          'YbVkJgDgbdX7vdBGAKopZMkzmQpIwNyAiuBJMk0A5hEscbh2575Ck4uAWlAV2LriAqNWAG500A5Z'
          '/D9ZkruAWmoF8LO8iAK4IU+igCggCogCooAoIAqIAqKAKCAK0J7lRRTADXkSBfwHAn4D8ftMU6uH'
          'F0IAAAAASUVORK5CYII=',
    ),
    SamplePhoto(
      id: 'water_leak',
      name: 'Burst Water Pipe',
      fileName: 'water_leak_evidence.png',
      description: 'High pressure municipal water spraying across roadway',
      // Valid 64x64 PNG: roadway pavement with spraying pipe and water pool
      base64Png:
          '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'
          'RU5ErkJggg==',
    ),
    SamplePhoto(
      id: 'graffiti',
      name: 'Public Park Graffiti',
      fileName: 'graffiti_evidence.png',
      description: 'Vandalism and spray paint on community center wall',
      // Valid 64x64 PNG: brick wall texture with vivid spray paint tag
      base64Png:
          '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',
    ),
  ];
}
