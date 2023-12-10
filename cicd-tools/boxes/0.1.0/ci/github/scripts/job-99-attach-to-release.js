// CI only script.

/**
 * @description Uploads files to a GitHub release.
 * (See the {@link https://github.com/actions/github-script|script action} repository for details.)
 *
 * @param {object} args.context - An object containing the context of the workflow run.
 * @param {object} args.fs - The fs module passed as an argument.
 * @param {string} args.folders - The newline separated list of folders who's content to attach to the release.
 * @param {object} args.core - A reference to the @actions/core package.
 * @param {object} args.github - A pre-authenticated octokit/rest.js client with pagination plugins.
 * @param {string} args.release - The release context.
 *
 */
module.exports = async ({ context, core, fs, folders, github, release }) => {
    console.debug(`DEBUG: -- ${__filename} --`);
    folders.trim().split('\n').forEach(async (folder) => {
        const relative_path = folder.trim()
        const files = fs.readdirSync(relative_path);
        files.forEach(async (file) => {
            try {
                upload_filename = file.trim();
                console.debug(`DEBUG: Uploading: '${upload_filename}' ...`)
                const result = await github.rest.repos.uploadReleaseAsset({
                    data: fs.readFileSync(relative_path + "/" + upload_filename),
                    headers: {
                        'content-type': 'application/octet-stream',
                    },
                    name: upload_filename,
                    owner: context.repo.owner,
                    release_id: release.data.id,
                    repo: context.repo.repo,
                })
                return result;
            } catch (error) {
                core.setFailed(error.message);
            }
        });

    })
}
