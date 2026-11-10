const repository = 'MekDrop/kryziukai-nuliukai.bat';

export async function renderReleaseLink(template, fetchRelease = fetch) {
    const response = await fetchRelease(`https://api.github.com/repos/${repository}/releases/latest`, {
        headers: { Accept: 'application/vnd.github+json' },
        signal: AbortSignal.timeout(30_000),
    });
    if (!response.ok) throw new Error(`Latest release lookup failed: HTTP ${response.status}`);
    const release = await response.json();
    if (typeof release.tag_name !== 'string' || !release.tag_name.trim()) {
        throw new Error('Latest release has no tag name');
    }
    const url = `https://github.com/${repository}/archive/refs/tags/${encodeURIComponent(release.tag_name)}.zip`;
    return template.replaceAll('{{LATEST_RELEASE_ZIP_URL}}', url);
}
