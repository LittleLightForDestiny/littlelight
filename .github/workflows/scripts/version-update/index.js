const core = require('@actions/core');
const github = require('@actions/github');
const fs = require('fs-extra');


const pubspecPath = "./pubspec.yaml";


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
function getWorkflowDispatchInputs() {
  let mappedArgs = {};
  try {
    mappedArgs['version'] = core.getInput('version');
    mappedArgs['changelog'] = core.getMultilineInput('changelog');
  } catch (e) { };
  if (mappedArgs.version) {
    return mappedArgs;
  }
  return null;
}

/**
 * @returns {Object.<string, string>}
 */
function getParams() {
  const workflowDispatchInput = getWorkflowDispatchInputs();
  if (workflowDispatchInput) return workflowDispatchInput;
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
 * @returns {Promise<bool>}
 */
async function updatePubspec(versionString, versionNumber) {
  const file = await fs.readFile(pubspecPath, "utf-8");
  const versionRegexp = /# application version\nversion: .*?\n/s;
  const changedFileContents = file.replace(versionRegexp, `# application version\nversion: ${versionString}+${versionNumber}\n`)
  console.log(changedFileContents);
  return true;
}


async function main() {
  const version = getVersionString();
  const versionNumber = getVersionNumber(version);
  await updatePubspec(version, versionNumber);
}

main();