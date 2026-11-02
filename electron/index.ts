import * as fs from 'fs';
import * as path from 'path';

const isDev = process.env.NODE_ENV === 'development';

if (isDev) {
  // In development, start the dev server
  require('electron-reloader')(module);
}

export { isDev };
