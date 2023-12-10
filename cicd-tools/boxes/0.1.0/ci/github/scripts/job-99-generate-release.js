// CI only script.

/**
 * @description Generates a GitHub release from the provided parameters.
 * (See the {@link https://github.com/actions/github-script|script action} repository for details.)
 *
 * @param {string} args.body - The content to attach to the release.
 * @param {object} args.context - An object containing the context of the workflow run.
 * @param {object} args.core - A reference to the @actions/core package.
 * @param {object} args.github - A pre-authenticated octokit/rest.js client with pagination plugins.
 * @param {string} args.tag - The name of the tag the release is for.
 *
 */
module.exports = async ({ body, context, core, github, tag }) => {
  try {
    console.debug(`DEBUG: -- ${__filename} --`);
    const releaseContext = await github.rest.repos.createRelease({
      body,
      draft: true,
      name: 'Release ' + tag,
      owner: context.repo.owner,
      prerelease: false,
      repo: context.repo.repo,
      tag_name: tag,
    })
    core.setOutput("RELEASE_CONTEXT", releaseContext);
  } catch (error) {
    core.setFailed(error.message)
  }
}
