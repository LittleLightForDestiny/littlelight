const fs = require('fs-extra');


const pubspecPath = "./pubspec.yaml";
const androidLanguages = ['de-DE', 'en-US', 'es-ES', 'fr-FR', 'it-IT', 'ja-JP', 'pt-BR'];
const iosLanguages = ['de-DE', 'default', 'en-US', 'es-ES', 'fr-FR', 'it', 'ja', 'pt-BR'];

/**
 * @returns {Object.<string, string>}
 */
function getCommandLineArgs() {
  let args = process.argv;
  let mappedArgs = {};
  for (let arg of args) {
    const regexp = /--(.*?)=(.*?)$/s;
    if (!regexp.test(arg)) continue;
    const groups = arg.match(regexp);
    const paramName = groups[1].replace('-', '');
    const paramValue = groups[2];
    mappedArgs[paramName] = paramValue.toString();
  }
  return mappedArgs;
}

/**
 * @returns {Object.<string, string>}
 */
function getParams() {
  return getCommandLineArgs();
}

/**
 * @returns {string}
 */
function getVersionString() {
  let version = getParams().version;

  return version.replace(/[^.0-9]/g, '');
}

/**
 * @returns {string}
 */
function getChangelog() {
  let changelog = getParams().changelog;
  return changelog;
}


/**
 * @param {string} versionNumber
 * @returns {string}
 */
function getVersionNumber(versionNumber) {
  const splitted = versionNumber.split('.');
  const major = splitted[0];
  const minor = splitted[1];
  const patch = splitted[2];
  return major + minor.padStart(3, '0') + patch.padStart(3, '0');
}

/**
 * @param {string} versionString
 * @param {string} versionNumber
 * @returns {Promise<void>}
 */
async function updatePubspec(versionString, versionNumber) {
  const file = await fs.readFile(pubspecPath, "utf-8");
  const versionRegexp = /# application version\nversion: .*?\n/s;
  const changedFileContents = file.replace(versionRegexp, `# application version\nversion: ${versionString}+${versionNumber}\n`)
  await fs.writeFile(pubspecPath, changedFileContents);
}

/**
 * @param {string} versionNumber
 * @param {string} versionNumber
 * @param {string} changelog
 * @returns {Promise<void>}
 */
async function updateChangelogs(versionString, versionNumber, changelog) {
  for (let language of androidLanguages) {
    const path = `./fastlane/metadata/android/${language}/changelogs/${versionNumber}.txt`;
    await fs.writeFile(path, changelog);
  }

  for (let language of iosLanguages) {
    const path = `./fastlane/metadata/ios/${language}/release_notes.txt`;
    await fs.writeFile(path, changelog);
  }

  let changelogsMD = "";
  try {
    changelogsMD = await fs.readFile('./CHANGELOG.md', 'utf-8');
  } catch (e) { }
  let currentVersionRegexp = RegExp("## \\[" + versionString.replace('.', '\\.') + "\\].*?## \\[", 's');
  let hasCurrentVersion = changelogsMD?.match(currentVersionRegexp);
  let date = new Date();
  let year = date.getFullYear().toString();
  let month = (date.getMonth() + 1).toString().padStart(2, '0');
  let day = (date.getDate()).toString().padStart(2, '0');
  let currentVersionText = "" +
    `## [${versionString}] - ${year}-${month}-${day}\n` +
    `\n` + changelog + `\n\n`;

  if (hasCurrentVersion) {
    changelogsMD = changelogsMD.replace(currentVersionRegexp, `${currentVersionText}## \[`)
  } else {
    changelogsMD = currentVersionText + (changelogsMD || '');
  }
  await fs.writeFile('./CHANGELOG.md', changelogsMD);
}


async function main() {
  const version = getVersionString();
  const versionNumber = getVersionNumber(version);
  const changelog = getChangelog();
  await updatePubspec(version, versionNumber);
  await updateChangelogs(version, versionNumber, changelog);
}

main();