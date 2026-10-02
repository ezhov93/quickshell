pragma Singleton

import Quickshell

Singleton {
  readonly property var entries: indexEntries(DesktopEntries.applications.values)

  function indexEntries(applications) {
    return applications.map(entry => ({
      entry: entry,
      name: (entry.name || "").toLowerCase(),
      fields: [entry.name, entry.genericName, ...(entry.keywords || []), ...(entry.categories || [])]
        .filter(Boolean).map(value => value.toLowerCase())
    })).sort((a, b) => a.entry.name.localeCompare(b.entry.name));
  }

  function search(text) {
    return filterEntries(entries, text);
  }

  function filterEntries(indexedEntries, text) {
    const query = text.trim().toLowerCase();
    if (!query) return indexedEntries.map(item => item.entry);
    const matches = indexedEntries.filter(item => item.fields.some(field => field.includes(query)));
    return matches.filter(item => item.name.startsWith(query))
      .concat(matches.filter(item => !item.name.startsWith(query))).map(item => item.entry);
  }

  function launch(entry): bool {
    if (!entry) return false;
    entry.execute();
    return true;
  }
}
