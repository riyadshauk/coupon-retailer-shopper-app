import 'mocha';
import {exec} from 'child_process';
describe('API should work / not be breaking', () => {
    it('should not emit any 400 errors from db_scripts/populator.ts', (done) => {
        exec('npm start | grep "status: 400"',
        (error, stdout, stderr) => {
            if (stdout.includes('status: 400') || stderr.includes('status: 400')) {
                done(new Error('Failure -- populator.ts emits "status: 400".'));
            } else {
                done();
            }
        });
    });
});