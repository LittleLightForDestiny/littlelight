const fs = require('fs-extra');
const {scale} = require('scale-that-svg');
const SVGIcons2SVGFontStream = require('svgicons2svgfont');
const svg2ttf = require('svg2ttf');
const Mustache = require('mustache');
const svgDim = require('svg-dimensions');


const startingIndex = 0xe000;

async function fetchFileList(){
    let files = await fs.readdir('svg');
    files = files.filter((value)=>value.indexOf('.svg') > -1);
    return files;
}

/**
 * 
 * @param {String[]} fileList 
 */
async function checkSVGDimensions(fileList){
    /**
     * @type {{filename:String, width:Number, height:number}[]} wrongDimensionFiles
     */
    let wrongDimensionFiles = [];

    for(var filename of fileList){
        let {width,height} = await getSVGDimension(filename);
        if(height!=32){
            wrongDimensionFiles.push({
                filename:filename,
                width:width,
                height:height
            });
        }
    }
    if(wrongDimensionFiles.length > 0){
        console.warn(`${wrongDimensionFiles.length} files are in the wrong size.`);
        for(var file of wrongDimensionFiles){
            console.warn(`  * ${file.filename}: ${file.width}x${file.height}`);
        }
    }
}

/**
 * 
 * @param {String} filename 
 * @returns {Promise<{width:Number, height:Number}>}
 */
function getSVGDimension(filename){
    return new Promise((resolve, reject)=>{
        svgDim.get(`./svg/${filename}`, (err, dim)=>{
            if(err){
                reject(err);
                return;
            }
            resolve(dim)
        });
    })
    
}

/**
 * 
 * @param {String[]} fileList 
 */
async function createScaledSVGs(fileList){
    await fs.ensureDir('./scaled-svg');
    for(var filename of fileList){
        await createScaledSVG(filename);
    }
}

/**
 * 
 * @param {String} filename 
 */
async function createScaledSVG(filename){
    var original = await fs.readFile(`./svg/${filename}`);
    var scaledData = await scale(original, {scale:32});
    await fs.writeFile(`./scaled-svg/${filename}`, scaledData);
}

/**
 * 
 * @param {String[]} fileList 
 */
async function writeSVGFont(fileList){
    await fs.ensureDir('./dist');
    return new Promise((resolve, reject)=>{
        const fontStream = new SVGIcons2SVGFontStream({
            fontName: 'LittleLightIcons',
        });
        fontStream.pipe(fs.createWriteStream('./dist/LittleLightIcons.svg')).on('finish',function() {
            resolve();
        })
        .on('error',function(err) {
            reject();
        });
        for(let i in fileList){
            let filename = fileList[i];
            let unicode = intToUnicode(i);
            let glyph = fs.createReadStream(`scaled-svg/${filename}`);
            glyph.metadata = {  
                unicode: [unicode],
                name: filename.replace('.svg', '')
            };
            fontStream.write(glyph);
        }
        fontStream.end();
    });
}

/**
 * 
 * @param {Number} int 
 */
function intToUnicode(int){
    var index = parseInt(int) + startingIndex;
    return String.fromCharCode(index);
}

async function writeTTFFont(){
    const ttf = svg2ttf(await fs.readFile('./dist/LittleLightIcons.svg', 'utf8'), {});
    await fs.writeFile('./../fonts/LittleLightIcons.ttf', Buffer.from(ttf.buffer));
}

/**
 * 
 * @param {String[]} fileList 
 */
async function writeDartClass(fileList){
    let hexlist = fileList.map((filename, index)=>({
        name:filename.replace('.svg', ''),
        hex:'0x' + (parseInt(index) + startingIndex).toString(16).padStart(4,'0')
    }));
    let template = (await fs.readFile('./dart_template/icons.dart.mustache')).toString();
    let dartFile = Mustache.render(template, {icons:hexlist});
    await fs.writeFile('./../lib/widgets/icon_fonts/littlelight_icons.dart', Buffer.from(dartFile));
}

async function cleanup(){
    await fs.remove('./scaled-svg/');
    await fs.remove('./dist/');
}

async function run(){
    let fileList = await fetchFileList();
    await checkSVGDimensions(fileList);
    await createScaledSVGs(fileList);   
    await writeSVGFont(fileList);
    await writeTTFFont();
    await writeDartClass(fileList);
    await cleanup();
}

run();
