import { readFile } from 'node:fs/promises';

export const siteUrl = 'https://mekdrop.github.io/kryziukai-nuliukai.bat/';

export async function loadLocales(language = 'all') {
    const configs = [
        { language: 'en', filename: 'index.html', path: '', ogLocale: 'en_US', alternateLocale: 'lt_LT' },
        { language: 'lt', filename: 'lt.html', path: 'lt.html', ogLocale: 'lt_LT', alternateLocale: 'en_US' },
    ].filter(config => language === 'all' || config.language === language);
    if (!configs.length) throw new Error('Language must be en, lt, or all.');
    return Promise.all(configs.map(async config => ({
        ...JSON.parse(await readFile(new URL(`./locales/${config.language}.json`, import.meta.url), 'utf8')),
        ...config,
        pageUrl: new URL(config.path, siteUrl).href,
        previewImageUrl: new URL(`og-game-${config.language}.png`, siteUrl).href,
        isEnglish: config.language === 'en',
        isLithuanian: config.language === 'lt',
    })));
}
