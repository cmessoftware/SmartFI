Módulo de gastos

Mejoras:
1. ✅ IMPLEMENTADO — Páginas con tamaño de 25 lineas cada una. Paginación con controles Anterior/Siguiente y números de página en TransactionReport.jsx.
2. ✅ IMPLEMENTADO — Tanto en carga individual como masiva desde csv, la categoria debe ser un campo requerido. Backend (Pydantic) y CSVImport ahora exigen categoría.
3. ✅ IMPLEMENTADO — Filtro para mostrar por mes. Por defecto mostrar los gastos del mes actual. Selector de mes/año en la barra de filtros de TransactionReport.jsx.
4. ✅ IMPLEMENTADO — En asignación de presupuesto, mostrar solo los items de presupuesto del mes del gasto. TransactionForm.jsx y EditTransactionModal.jsx filtran por YYYY-MM de la fecha.
5. ✅ IMPLEMENTADO — Selector de mes/año con navegación ◀ ▶ y botón "Hoy" en página Reportes (TransactionReport.jsx). Misma funcionalidad que el Panel Principal: barra visual prominente, dropdown de mes y año, navegación con wrapping mes/año.
6. ✅ IMPLEMENTADO — Normalización de categorías: tabla categories poblada con datos existentes + hardcoded, campo category_id (FK) en transactions, API /api/categories retorna [{id, name}], frontend usa objetos categoría. Migración Alembic b5e8f2a1c3d7.
7. ✅ IMPLEMENTADO — Campos de transactions renombrados a inglés: marca_temporal→timestamp, fecha→date, tipo→type, categoria→category_id, monto→amount, necesidad→necessity, forma_pago→payment_method, detalle→detail, estado_asignacion→assignment_status. Backend (main.py, database_service.py, google_sheets.py) y frontend (6 componentes) actualizados.


Bugs:
1. ~~Prioridad: Alta~~ ✅ RESUELTO — El frontend usaba `id: Date.now()` como id de transacción en lugar del id real de la DB. Al editar, enviaba PUT con un timestamp (ej: 1775000505766) que no existía en PostgreSQL → 500. Fix: se eliminó `Date.now()` de TransactionForm.jsx y CSVImport.jsx, y `addTransaction` en App.jsx ahora usa el `id` real devuelto por la API.

 <details>
    <summary>Error al editar asignación de item de presupuesto
    api.js:58  PUT http://localhost:8000/api/transactions/1775000505766 500 (Internal Server Error)
    dispatchXhrRequest @ axios.js?v=00a09b6a:1784
    xhr @ axios.js?v=00a09b6a:1649
    dispatchRequest @ axios.js?v=00a09b6a:2210
    Promise.then
    _request @ axios.js?v=00a09b6a:2428
    request @ axios.js?v=00a09b6a:2324
    httpMethod @ axios.js?v=00a09b6a:2476
    wrap @ axios.js?v=00a09b6a:8
    updateTransaction @ api.js:58
    updateTransaction @ App.jsx:156
    handleSaveEdit @ Dashboard.jsx:46
    handleSubmit @ EditTransactionModal.jsx:40
    callCallback2 @ chunk-NUMECXU6.js?v=00a09b6a:3674
    invokeGuardedCallbackDev @ chunk-NUMECXU6.js?v=00a09b6a:3699
    invokeGuardedCallback @ chunk-NUMECXU6.js?v=00a09b6a:3733
    invokeGuardedCallbackAndCatchFirstError @ chunk-NUMECXU6.js?v=00a09b6a:3736
    executeDispatch @ chunk-NUMECXU6.js?v=00a09b6a:7014
    processDispatchQueueItemsInOrder @ chunk-NUMECXU6.js?v=00a09b6a:7034
    processDispatchQueue @ chunk-NUMECXU6.js?v=00a09b6a:7043
    dispatchEventsForPlugins @ chunk-NUMECXU6.js?v=00a09b6a:7051
    (anonymous) @ chunk-NUMECXU6.js?v=00a09b6a:7174
    batchedUpdates$1 @ chunk-NUMECXU6.js?v=00a09b6a:18913
    batchedUpdates @ chunk-NUMECXU6.js?v=00a09b6a:3579
    dispatchEventForPluginEventSystem @ chunk-NUMECXU6.js?v=00a09b6a:7173
    dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ chunk-NUMECXU6.js?v=00a09b6a:5478
    dispatchEvent @ chunk-NUMECXU6.js?v=00a09b6a:5472
    dispatchDiscreteEvent @ chunk-NUMECXU6.js?v=00a09b6a:5449
    installHook.js:1 ❌ Error updating transaction: AxiosError: Request failed with status code 500
        at settle (axios.js?v=00a09b6a:1319:7)
        at XMLHttpRequest.onloadend (axios.js?v=00a09b6a:1682:7)
        at Axios.request (axios.js?v=00a09b6a:2328:41)
        at async updateTransaction (App.jsx:156:7)
        at async handleSaveEdit (Dashboard.jsx:46:7)
    overrideMethod @ installHook.js:1
    updateTransaction @ App.jsx:166
    await in updateTransaction
    handleSaveEdit @ Dashboard.jsx:46
    handleSubmit @ EditTransactionModal.jsx:40
    callCallback2 @ chunk-NUMECXU6.js?v=00a09b6a:3674
    invokeGuardedCallbackDev @ chunk-NUMECXU6.js?v=00a09b6a:3699
    invokeGuardedCallback @ chunk-NUMECXU6.js?v=00a09b6a:3733
    invokeGuardedCallbackAndCatchFirstError @ chunk-NUMECXU6.js?v=00a09b6a:3736
    executeDispatch @ chunk-NUMECXU6.js?v=00a09b6a:7014
    processDispatchQueueItemsInOrder @ chunk-NUMECXU6.js?v=00a09b6a:7034
    processDispatchQueue @ chunk-NUMECXU6.js?v=00a09b6a:7043
    dispatchEventsForPlugins @ chunk-NUMECXU6.js?v=00a09b6a:7051
    (anonymous) @ chunk-NUMECXU6.js?v=00a09b6a:7174
    batchedUpdates$1 @ chunk-NUMECXU6.js?v=00a09b6a:18913
    batchedUpdates @ chunk-NUMECXU6.js?v=00a09b6a:3579
    dispatchEventForPluginEventSystem @ chunk-NUMECXU6.js?v=00a09b6a:7173
    dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ chunk-NUMECXU6.js?v=00a09b6a:5478
    dispatchEvent @ chunk-NUMECXU6.js?v=00a09b6a:5472
    dispatchDiscreteEvent @ chunk-NUMECXU6.js?v=00a09b6a:5449
    installHook.js:1 AxiosError: Request failed with status code 500
        at settle (axios.js?v=00a09b6a:1319:7)
        at XMLHttpRequest.onloadend (axios.js?v=00a09b6a:1682:7)
        at Axios.request (axios.js?v=00a09b6a:2328:41)
        at async updateTransaction (App.jsx:156:7)
        at async handleSaveEdit (Dashboard.jsx:46:7)
    overrideMethod @ installHook.js:1
    handleSaveEdit @ Dashboard.jsx:53
    await in handleSaveEdit
    handleSubmit @ EditTransactionModal.jsx:40
    callCallback2 @ chunk-NUMECXU6.js?v=00a09b6a:3674
    invokeGuardedCallbackDev @ chunk-NUMECXU6.js?v=00a09b6a:3699
    invokeGuardedCallback @ chunk-NUMECXU6.js?v=00a09b6a:3733
    invokeGuardedCallbackAndCatchFirstError @ chunk-NUMECXU6.js?v=00a09b6a:3736
    executeDispatch @ chunk-NUMECXU6.js?v=00a09b6a:7014
    processDispatchQueueItemsInOrder @ chunk-NUMECXU6.js?v=00a09b6a:7034
    processDispatchQueue @ chunk-NUMECXU6.js?v=00a09b6a:7043
    dispatchEventsForPlugins @ chunk-NUMECXU6.js?v=00a09b6a:7051
    (anonymous) @ chunk-NUMECXU6.js?v=00a09b6a:7174
    batchedUpdates$1 @ chunk-NUMECXU6.js?v=00a09b6a:18913
    batchedUpdates @ chunk-NUMECXU6.js?v=00a09b6a:3579
    dispatchEventForPluginEventSystem @ chunk-NUMECXU6.js?v=00a09b6a:7173
    dispatchEventWithEnableCapturePhaseSelectiveHydrationWithoutDiscreteEventReplay @ chunk-NUMECXU6.js?v=00a09b6a:5478
    dispatchEvent @ chunk-NUMECXU6.js?v=00a09b6a:5472
    dispatchDiscreteEvent @ chunk-NUMECXU6.js?v=00a09b6a:5449
   </details>

