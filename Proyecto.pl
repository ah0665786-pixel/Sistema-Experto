% ====================================
% HECHOS DINAMICOS
% ====================================

:- dynamic respuesta/2.
:- dynamic historial/5.


% ====================================
% INICIO
% ====================================

inicio :-
    limpiar,
    nl,
    write('============================================================'), nl,
    write('     ASISTENTE DE CUMPLIMIENTO NORMATIVO RGPD v3.0          '), nl,
    write('     Reglamento (UE) 2016/679 - Proteccion de Datos         '), nl,
    write('============================================================'), nl,
    menu.


% ====================================
% MENU PRINCIPAL
% ====================================

menu :-
    nl,
    write('------------------------------------------------------------'), nl,
    write(' MENU PRINCIPAL                                              '), nl,
    write('------------------------------------------------------------'), nl,
    write('  1. Evaluar empresa o sitio web                            '), nl,
    write('  2. Ver historial de evaluaciones                          '), nl,
    write('  3. Explicar ultimo resultado                              '), nl,
    write('  4. Salir                                                  '), nl,
    write('------------------------------------------------------------'), nl,
    write('Seleccione una opcion: '),
    read(Opcion),
    opcion(Opcion).

opcion(1) :- evaluar.
opcion(2) :- ver_historial.
opcion(3) :- explicar_ultimo.
opcion(4) :- write('Saliendo del sistema. Hasta luego.'), nl.
opcion(_) :-
    write('Opcion invalida. Intente de nuevo.'), nl,
    menu.


% ====================================
% LIMPIAR RESPUESTAS
% ====================================

limpiar :-
    retractall(respuesta(_, _)).


% ====================================
% HACER PREGUNTAS
% ====================================

preguntar(Pregunta, Articulo) :-
    repeat,
    nl,
    write('  ['), write(Articulo), write(']'), nl,
    write('  '), write(Pregunta), nl,
    write('  Respuesta (si/no): '),
    read(Respuesta),
    nl,
    (
        Respuesta = si ->
        assert(respuesta(Pregunta, si)), !
    ;
        Respuesta = no ->
        assert(respuesta(Pregunta, no)), !
    ;
        write('  Respuesta invalida. Escriba si. o no.'), nl,
        fail
    ).


% ====================================
% EVALUAR EMPRESA
% ====================================

evaluar :-
    limpiar,
    nl,
    write('============================================================'), nl,
    write(' NUEVA EVALUACION DE CUMPLIMIENTO RGPD                      '), nl,
    write('============================================================'), nl,
    nl,
    write('Ingrese el nombre de la empresa o sitio web: '),
    read(Empresa),
    nl,
    write('------------------------------------------------------------'), nl,
    write(' CATEGORIA 1: CONSENTIMIENTO Y BASE LEGAL (Art. 6 y 7)     '), nl,
    write('------------------------------------------------------------'), nl,
    preguntar('La empresa solicita consentimiento explicito para usar datos personales',
              'Art. 6 - Licitud del tratamiento'),
    preguntar('El consentimiento puede ser retirado facilmente por el usuario',
              'Art. 7 - Condiciones del consentimiento'),
    nl,
    write('------------------------------------------------------------'), nl,
    write(' CATEGORIA 2: TRANSPARENCIA E INFORMACION (Art. 12-14)     '), nl,
    write('------------------------------------------------------------'), nl,
    preguntar('El sitio tiene aviso o politica de privacidad visible',
              'Art. 13 - Informacion al recoger datos'),
    preguntar('Se informa claramente para que se usaran los datos del usuario',
              'Art. 14 - Informacion cuando no se obtienen del interesado'),
    preguntar('El sitio informa sobre el uso de cookies antes de activarlas',
              'Directiva ePrivacy - Cookies'),
    nl,
    write('------------------------------------------------------------'), nl,
    write(' CATEGORIA 3: DERECHOS DEL USUARIO (Art. 15-22)            '), nl,
    write('------------------------------------------------------------'), nl,
    preguntar('Los usuarios pueden acceder a sus datos personales',
              'Art. 15 - Derecho de acceso'),
    preguntar('Los usuarios pueden corregir sus datos incorrectos',
              'Art. 16 - Derecho de rectificacion'),
    preguntar('Los usuarios pueden solicitar eliminar sus datos',
              'Art. 17 - Derecho al olvido'),
    preguntar('Los usuarios pueden oponerse al uso de sus datos',
              'Art. 21 - Derecho de oposicion'),
    nl,
    write('------------------------------------------------------------'), nl,
    write(' CATEGORIA 4: SEGURIDAD TECNICA (Art. 32)                  '), nl,
    write('------------------------------------------------------------'), nl,
    preguntar('La empresa protege datos con cifrado o contrasenas seguras',
              'Art. 32 - Seguridad del tratamiento'),
    preguntar('Existe un protocolo para detectar y contener brechas de datos',
              'Art. 33 - Notificacion de brechas de seguridad'),
    nl,
    write('------------------------------------------------------------'), nl,
    write(' CATEGORIA 5: RESPONSABILIDAD ORGANIZACIONAL (Art. 24-30)  '), nl,
    write('------------------------------------------------------------'), nl,
    preguntar('Se documentan las actividades de tratamiento de datos',
              'Art. 30 - Registro de actividades de tratamiento'),
    preguntar('Solo se recopilan los datos estrictamente necesarios',
              'Art. 5 - Minimizacion de datos'),
    diagnostico(Empresa).


% ====================================
% CALCULAR PUNTAJE
% ====================================

calcular_puntaje(Puntaje, Cumplidas, Total) :-
    findall(P, respuesta(P, si), ListaSi),
    length(ListaSi, Cumplidas),
    findall(P, respuesta(P, _), ListaTodo),
    length(ListaTodo, Total),
    (Total > 0 -> Puntaje is round((Cumplidas * 100) / Total) ; Puntaje = 0).


% ====================================
% NIVEL DE RIESGO
% ====================================

nivel_riesgo(Puntaje, 'BAJO - La empresa tiene buenas practicas de proteccion de datos') :-
    Puntaje >= 80, !.

nivel_riesgo(Puntaje, 'MEDIO - La empresa necesita mejoras en algunas areas') :-
    Puntaje >= 50, !.

nivel_riesgo(_, 'ALTO - La empresa presenta incumplimientos graves del RGPD').


% ====================================
% DIAGNOSTICO
% ====================================

diagnostico(Empresa) :-
    calcular_puntaje(Puntaje, _Cumplidas, Total),
    nivel_riesgo(Puntaje, Riesgo),
    generar_recomendaciones(ListaRec),
    determinar_resultado(Puntaje, Resultado),
    assert(historial(Empresa, Resultado, Puntaje, Riesgo, ListaRec)),
    nl,
    write('============================================================'), nl,
    write(' RESULTADO DE LA EVALUACION                                 '), nl,
    write('============================================================'), nl,
    write(' Empresa evaluada : '), write(Empresa), nl,
    write(' Resultado        : '), write(Resultado), nl,
    write(' Puntaje          : '), write(Puntaje), write('%  ('), write(Total), write(' preguntas)'), nl,
    write(' Nivel de riesgo  : '), write(Riesgo), nl,
    write('============================================================'), nl,
    mostrar_incumplimientos,
    mostrar_recomendaciones,
    nl,
    write(' Puede seleccionar la opcion 3 del menu para ver la        '), nl,
    write(' explicacion detallada de por que se llego a este resultado.'), nl,
    menu.

determinar_resultado(Puntaje, 'CUMPLE COMPLETAMENTE CON EL RGPD') :-
    Puntaje =:= 100, !.
determinar_resultado(Puntaje, 'CUMPLIMIENTO PARCIAL DEL RGPD') :-
    Puntaje >= 50, !.
determinar_resultado(_, 'NO CUMPLE CON EL RGPD').


% ====================================
% MOSTRAR INCUMPLIMIENTOS
% ====================================

mostrar_incumplimientos :-
    nl,
    write(' AREAS EN INCUMPLIMIENTO:'), nl,
    write('------------------------------------------------------------'), nl,
    (
        respuesta(Pregunta, no),
        articulo_de(Pregunta, Articulo),
        write('  [x] '), write(Pregunta), nl,
        write('      -> '), write(Articulo), nl,
        fail
    ;
        true
    ).


% ====================================
% ARTICULO ASOCIADO A PREGUNTA
% ====================================

articulo_de('La empresa solicita consentimiento explicito para usar datos personales',
            'Violacion Art. 6 - Licitud del tratamiento').
articulo_de('El consentimiento puede ser retirado facilmente por el usuario',
            'Violacion Art. 7 - Condiciones del consentimiento').
articulo_de('El sitio tiene aviso o politica de privacidad visible',
            'Violacion Art. 13 - Informacion al recoger datos').
articulo_de('Se informa claramente para que se usaran los datos del usuario',
            'Violacion Art. 14 - Deber de informacion').
articulo_de('El sitio informa sobre el uso de cookies antes de activarlas',
            'Violacion Directiva ePrivacy - Uso de cookies').
articulo_de('Los usuarios pueden acceder a sus datos personales',
            'Violacion Art. 15 - Derecho de acceso del interesado').
articulo_de('Los usuarios pueden corregir sus datos incorrectos',
            'Violacion Art. 16 - Derecho de rectificacion').
articulo_de('Los usuarios pueden solicitar eliminar sus datos',
            'Violacion Art. 17 - Derecho de supresion (derecho al olvido)').
articulo_de('Los usuarios pueden oponerse al uso de sus datos',
            'Violacion Art. 21 - Derecho de oposicion').
articulo_de('La empresa protege datos con cifrado o contrasenas seguras',
            'Violacion Art. 32 - Seguridad del tratamiento').
articulo_de('Existe un protocolo para detectar y contener brechas de datos',
            'Violacion Art. 33 - Notificacion de violaciones de seguridad').
articulo_de('Se documentan las actividades de tratamiento de datos',
            'Violacion Art. 30 - Registro de actividades de tratamiento').
articulo_de('Solo se recopilan los datos estrictamente necesarios',
            'Violacion Art. 5 - Principio de minimizacion de datos').


% ====================================
% PRIORIDAD DE ARTICULOS
% ====================================

% Define que tan critico es cada articulo (1=mas critico)
prioridad_articulo('La empresa solicita consentimiento explicito para usar datos personales', 1).
prioridad_articulo('El consentimiento puede ser retirado facilmente por el usuario', 2).
prioridad_articulo('El sitio tiene aviso o politica de privacidad visible', 3).
prioridad_articulo('Se informa claramente para que se usaran los datos del usuario', 4).
prioridad_articulo('La empresa protege datos con cifrado o contrasenas seguras', 5).
prioridad_articulo('Existe un protocolo para detectar y contener brechas de datos', 6).
prioridad_articulo('Los usuarios pueden solicitar eliminar sus datos', 7).
prioridad_articulo('Los usuarios pueden acceder a sus datos personales', 8).
prioridad_articulo('Los usuarios pueden corregir sus datos incorrectos', 9).
prioridad_articulo('Los usuarios pueden oponerse al uso de sus datos', 10).
prioridad_articulo('El sitio informa sobre el uso de cookies antes de activarlas', 11).
prioridad_articulo('Se documentan las actividades de tratamiento de datos', 12).
prioridad_articulo('Solo se recopilan los datos estrictamente necesarios', 13).

% Explica por que un articulo es critico
razon_criticidad('La empresa solicita consentimiento explicito para usar datos personales',
    'Es la BASE LEGAL del tratamiento. Sin consentimiento, NINGUN uso de datos es legal.').
razon_criticidad('El consentimiento puede ser retirado facilmente por el usuario',
    'El RGPD exige que retirar el consentimiento sea tan facil como darlo.').
razon_criticidad('El sitio tiene aviso o politica de privacidad visible',
    'Principio de transparencia: el usuario debe saber como se usan sus datos.').
razon_criticidad('Se informa claramente para que se usaran los datos del usuario',
    'El usuario tiene derecho a conocer la finalidad exacta del tratamiento.').
razon_criticidad('La empresa protege datos con cifrado o contrasenas seguras',
    'Sin seguridad tecnica los datos quedan expuestos a filtraciones y ataques.').
razon_criticidad('Existe un protocolo para detectar y contener brechas de datos',
    'La ley exige notificar brechas en 72 horas. Sin protocolo esto es imposible.').
razon_criticidad('Los usuarios pueden solicitar eliminar sus datos',
    'El derecho al olvido es un derecho fundamental reconocido por el RGPD.').
razon_criticidad('Los usuarios pueden acceder a sus datos personales',
    'Todo usuario tiene derecho a saber que datos tiene la empresa sobre el.').
razon_criticidad('Los usuarios pueden corregir sus datos incorrectos',
    'Datos incorrectos pueden causar perjuicios al usuario, debe poder corregirlos.').
razon_criticidad('Los usuarios pueden oponerse al uso de sus datos',
    'El usuario puede oponerse al uso de sus datos para marketing o perfilado.').
razon_criticidad('El sitio informa sobre el uso de cookies antes de activarlas',
    'Las cookies recopilan datos de navegacion y requieren consentimiento previo.').
razon_criticidad('Se documentan las actividades de tratamiento de datos',
    'El registro de actividades demuestra responsabilidad proactiva ante la ley.').
razon_criticidad('Solo se recopilan los datos estrictamente necesarios',
    'El principio de minimizacion prohíbe recopilar mas datos de los necesarios.').


% ====================================
% GENERAR Y MOSTRAR RECOMENDACIONES
% ====================================

generar_recomendaciones(Lista) :-
    findall(R, recomendacion(R), Lista).

recomendacion('Art.6  - Implemente un mecanismo de consentimiento explicito (checkbox, formulario) antes de recopilar datos') :-
    respuesta('La empresa solicita consentimiento explicito para usar datos personales', no).

recomendacion('Art.7  - Agregue un boton o enlace visible para que los usuarios retiren su consentimiento en cualquier momento') :-
    respuesta('El consentimiento puede ser retirado facilmente por el usuario', no).

recomendacion('Art.13 - Publique una Politica de Privacidad accesible desde todas las paginas del sitio') :-
    respuesta('El sitio tiene aviso o politica de privacidad visible', no).

recomendacion('Art.14 - Especifique claramente la finalidad del tratamiento de datos en su aviso de privacidad') :-
    respuesta('Se informa claramente para que se usaran los datos del usuario', no).

recomendacion('ePrivacy - Implemente un banner de cookies con opciones de aceptar/rechazar antes de cargar rastreadores') :-
    respuesta('El sitio informa sobre el uso de cookies antes de activarlas', no).

recomendacion('Art.15 - Cree un portal o proceso para que los usuarios soliciten acceso a sus datos personales') :-
    respuesta('Los usuarios pueden acceder a sus datos personales', no).

recomendacion('Art.16 - Habilite un mecanismo para que los usuarios corrijan datos inexactos o desactualizados') :-
    respuesta('Los usuarios pueden corregir sus datos incorrectos', no).

recomendacion('Art.17 - Implemente un proceso de eliminacion de datos a solicitud del usuario en un plazo de 30 dias') :-
    respuesta('Los usuarios pueden solicitar eliminar sus datos', no).

recomendacion('Art.21 - Permita a los usuarios oponerse al uso de sus datos para marketing o elaboracion de perfiles') :-
    respuesta('Los usuarios pueden oponerse al uso de sus datos', no).

recomendacion('Art.32 - Implemente cifrado TLS/SSL, hashing de contrasenas y control de acceso por roles') :-
    respuesta('La empresa protege datos con cifrado o contrasenas seguras', no).

recomendacion('Art.33 - Desarrolle un plan de respuesta a incidentes: debe notificar brechas a la autoridad en 72 horas') :-
    respuesta('Existe un protocolo para detectar y contener brechas de datos', no).

recomendacion('Art.30 - Mantenga un registro escrito de todas las actividades de tratamiento de datos personales') :-
    respuesta('Se documentan las actividades de tratamiento de datos', no).

recomendacion('Art.5  - Revise que formularios y sistemas solo soliciten datos estrictamente necesarios (minimizacion)') :-
    respuesta('Solo se recopilan los datos estrictamente necesarios', no).


mostrar_recomendaciones :-
    generar_recomendaciones(Lista),
    (Lista = [] ->
        nl,
        write(' Sin recomendaciones. La empresa cumple con todos los requisitos.'), nl
    ;
        nl,
        write(' RECOMENDACIONES DE MEJORA:'), nl,
        write('------------------------------------------------------------'), nl,
        mostrar_lista_recomendaciones(Lista)
    ).

mostrar_lista_recomendaciones([]).
mostrar_lista_recomendaciones([H|T]) :-
    write('  [*] '), write(H), nl,
    mostrar_lista_recomendaciones(T).


% ====================================
% MODULO DE EXPLICACIONES
% ====================================

explicar_ultimo :-
    (
        \+ respuesta(_, _) ->
        nl,
        write('  No hay una evaluacion reciente en memoria.'), nl,
        write('  Realice primero una evaluacion (opcion 1).'), nl
    ;
        nl,
        write('============================================================'), nl,
        write(' MODULO DE EXPLICACIONES - POR QUE SE LLEGO A ESTE RESULTADO'), nl,
        write('============================================================'), nl,
        explicar_paso1,
        explicar_paso2,
        explicar_paso3,
        explicar_paso4,
        explicar_paso5,
        nl,
        write('============================================================'), nl,
        write(' FIN DE LA EXPLICACION                                      '), nl,
        write('============================================================'), nl
    ),
    menu.


% PASO 1: Conteo de respuestas y calculo del puntaje

explicar_paso1 :-
    calcular_puntaje(Puntaje, Cumplidas, Total),
    Fallidas is Total - Cumplidas,
    nl,
    write(' PASO 1 - COMO SE CALCULO EL PUNTAJE:'), nl,
    write('------------------------------------------------------------'), nl,
    write('  Total de preguntas evaluadas : '), write(Total), nl,
    write('  Respuestas SI (cumple)        : '), write(Cumplidas), nl,
    write('  Respuestas NO (incumple)      : '), write(Fallidas), nl,
    write('  Formula aplicada             : ('), write(Cumplidas),
    write(' x 100) / '), write(Total), write(' = '), write(Puntaje), write('%'), nl.


% PASO 2: Criterio usado para determinar el resultado

explicar_paso2 :-
    calcular_puntaje(Puntaje, _, _),
    determinar_resultado(Puntaje, Resultado),
    nl,
    write(' PASO 2 - CRITERIO PARA DETERMINAR EL RESULTADO:'), nl,
    write('------------------------------------------------------------'), nl,
    write('  Regla 1: Puntaje = 100%          -> Cumple completamente'), nl,
    write('  Regla 2: Puntaje entre 50% y 99% -> Cumplimiento parcial'), nl,
    write('  Regla 3: Puntaje menor a 50%     -> No cumple'), nl,
    nl,
    write('  Puntaje obtenido : '), write(Puntaje), write('%'), nl,
    write('  Regla aplicada   : '), write(Resultado), nl.


% PASO 3: Criterio usado para determinar el nivel de riesgo

explicar_paso3 :-
    calcular_puntaje(Puntaje, _, _),
    nivel_riesgo(Puntaje, Riesgo),
    nl,
    write(' PASO 3 - CRITERIO PARA DETERMINAR EL NIVEL DE RIESGO:'), nl,
    write('------------------------------------------------------------'), nl,
    write('  Nivel BAJO  : Puntaje mayor o igual a 80%'), nl,
    write('  Nivel MEDIO : Puntaje mayor o igual a 50%'), nl,
    write('  Nivel ALTO  : Puntaje menor a 50%'), nl,
    nl,
    write('  Puntaje obtenido : '), write(Puntaje), write('%'), nl,
    write('  Nivel asignado   : '), write(Riesgo), nl.


% PASO 4: Detalle de cada pregunta respondida con su justificacion

explicar_paso4 :-
    nl,
    write(' PASO 4 - DETALLE DE CADA RESPUESTA Y SU IMPACTO:'), nl,
    write('------------------------------------------------------------'), nl,
    (
        respuesta(Pregunta, Resp),
        articulo_de(Pregunta, Articulo),
        razon_criticidad(Pregunta, Razon),
        (Resp = si ->
            write('  [OK] ')
        ;
            write('  [XX] ')
        ),
        write(Pregunta), nl,
        write('        Articulo : '), write(Articulo), nl,
        write('        Por que importa: '), write(Razon), nl,
        write('        Respuesta dada : '), write(Resp), nl,
        nl,
        fail
    ;
        true
    ).


% PASO 5: Falla mas critica detectada

explicar_paso5 :-
    nl,
    write(' PASO 5 - FALLA MAS CRITICA DETECTADA:'), nl,
    write('------------------------------------------------------------'), nl,
    (
        \+ respuesta(_, no) ->
        write('  No se detectaron fallas. La empresa cumple con todo.'), nl
    ;
        encontrar_falla_critica(PreguntaCritica),
        articulo_de(PreguntaCritica, Articulo),
        razon_criticidad(PreguntaCritica, Razon),
        write('  Falla prioritaria : '), write(PreguntaCritica), nl,
        write('  Articulo violado  : '), write(Articulo), nl,
        write('  Por que es critica: '), write(Razon), nl,
        write('  Accion urgente    : Corrija esta falla antes que cualquier otra.'), nl
    ).


% Encuentra la falla con mayor prioridad (numero mas bajo)

encontrar_falla_critica(PreguntaCritica) :-
    findall(Prioridad-Pregunta,
        (respuesta(Pregunta, no), prioridad_articulo(Pregunta, Prioridad)),
        Lista),
    msort(Lista, [_-PreguntaCritica|_]).


% ====================================
% VER HISTORIAL
% ====================================

ver_historial :-
    nl,
    write('============================================================'), nl,
    write(' HISTORIAL DE EVALUACIONES                                  '), nl,
    write('============================================================'), nl,
    (
        \+ historial(_, _, _, _, _) ->
        write(' No hay evaluaciones registradas.'), nl
    ;
        (
            historial(Empresa, Resultado, Puntaje, Riesgo, Recs),
            nl,
            write(' Empresa  : '), write(Empresa), nl,
            write(' Resultado: '), write(Resultado), nl,
            write(' Puntaje  : '), write(Puntaje), write('%'), nl,
            write(' Riesgo   : '), write(Riesgo), nl,
            write(' Recomendaciones pendientes: '),
            length(Recs, N), write(N), nl,
            write('------------------------------------------------------------'), nl,
            fail
        ;
            true
        )
    ),
    menu.