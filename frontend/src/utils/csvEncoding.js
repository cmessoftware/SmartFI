const replacementCharRegex = /\uFFFD/g;

const countReplacementChars = (text) => {
  const matches = text.match(replacementCharRegex);
  return matches ? matches.length : 0;
};

export const decodeCsvFile = async (file) => {
  const buffer = await file.arrayBuffer();

  const utf8Text = new TextDecoder('utf-8', { fatal: false }).decode(buffer);
  const windows1252Text = new TextDecoder('windows-1252', { fatal: false }).decode(buffer);

  const utf8Score = countReplacementChars(utf8Text);
  const windows1252Score = countReplacementChars(windows1252Text);

  const useWindows1252 = windows1252Score < utf8Score;
  const decodedText = (useWindows1252 ? windows1252Text : utf8Text).replace(/^\uFEFF/, '');

  return {
    text: decodedText,
    encoding: useWindows1252 ? 'windows-1252' : 'utf-8'
  };
};
