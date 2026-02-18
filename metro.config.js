const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Override resolver to use expo-router/entry as main entry point
config.resolver = {
  ...config.resolver,
  resolveRequest: (context, moduleName, platform) => {
    if (moduleName === './index' || moduleName === 'index') {
      return context.resolveRequest(context, 'expo-router/entry', platform);
    }
    return context.resolveRequest(context, moduleName, platform);
  },
};

module.exports = config;