module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./src'],
        alias: {
          '@domain': './src/domain',
          '@platform': './src/platform',
          '@screens': './src/screens',
          '@store': './src/store',
          '@services': './src/services',
          '@types': './src/types',
          '@navigation': './src/navigation',
        },
      },
    ],
  ],
};
