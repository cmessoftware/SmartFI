/**
 * Formatea una fecha a formato DD/MM/YYYY
 * @param {string} dateString - Fecha en formato ISO (YYYY-MM-DD) o DD/MM/YYYY
 * @returns {string} Fecha formateada como DD/MM/YYYY
 */
export const formatDate = (dateString) => {
  if (!dateString) return '';
  
  // Si ya está en formato DD/MM/YYYY, devolverlo tal cual
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateString)) {
    return dateString;
  }
  
  // Si está en formato ISO (YYYY-MM-DD), convertir a DD/MM/YYYY
  if (/^\d{4}-\d{2}-\d{2}/.test(dateString)) {
    const date = new Date(dateString + 'T00:00:00');
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}/${month}/${year}`;
  }
  
  // Intentar parsear cualquier otro formato
  try {
    const date = new Date(dateString);
    if (!isNaN(date.getTime())) {
      const day = String(date.getDate()).padStart(2, '0');
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const year = date.getFullYear();
      return `${day}/${month}/${year}`;
    }
  } catch (e) {
    console.error('Error parsing date:', dateString, e);
  }
  
  // Si no se pudo parsear, devolver el string original
  return dateString;
};

/**
 * Formatea una fecha a formato ISO (YYYY-MM-DD) para inputs de tipo date
 * @param {string} dateString - Fecha en cualquier formato
 * @returns {string} Fecha formateada como YYYY-MM-DD
 */
export const toISODate = (dateString) => {
  if (!dateString) return '';
  
  // Si ya está en formato ISO, devolverlo tal cual
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    return dateString;
  }
  
  // Si está en formato DD/MM/YYYY, convertir a YYYY-MM-DD
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(dateString)) {
    const [day, month, year] = dateString.split('/');
    return `${year}-${month}-${day}`;
  }
  
  // Intentar parsear cualquier otro formato
  try {
    const date = new Date(dateString);
    if (!isNaN(date.getTime())) {
      return date.toISOString().split('T')[0];
    }
  } catch (e) {
    console.error('Error parsing date:', dateString, e);
  }
  
  return dateString;
};
