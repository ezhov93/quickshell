pragma Singleton

import Quickshell

Singleton {
  readonly property var entries: DesktopEntries.applications.values.map(entry => ({
    entry: entry,
    name: (entry.name || "").toLowerCase(),
    fields: [entry.name, entry.genericName, ...(entry.keywords || []), ...(entry.categories || [])]
      .filter(Boolean).map(value => value.toLowerCase())
  })).sort((a, b) => a.entry.name.localeCompare(b.entry.name))

  function search(text) {
    const query = text.trim().toLowerCase();
    if (!query) return entries.map(item => item.entry);
    const matches = entries.filter(item => item.fields.some(field => field.includes(query)));
    return matches.filter(item => item.name.startsWith(query))
      .concat(matches.filter(item => !item.name.startsWith(query))).map(item => item.entry);
  }
}
