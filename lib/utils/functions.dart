import 'dart:convert';
import 'dart:io';

import 'package:ecf_dgii/ecf_dgii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/apis/electronic.ncf.api.request.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
void showTopSnackBar(BuildContext context,
    {required String message,
    Color color = Colors.black,
    Color fontColor = Colors.white}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: Duration(milliseconds: 200),
  );
  final animation =
      Tween<double>(begin: -50, end: 50).animate(animationController);

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Positioned(
        top: animation.value,
        left: 20,
        right: 20,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          color: color,
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    message,
                    style: TextStyle(color: fontColor, fontSize: 16),
                  )),
                  IconButton(
                      onPressed: () {
                        animationController.reverse().then((_) {
                          overlayEntry.remove();
                          animationController.dispose();
                        });
                      },
                      icon: Icon(Icons.close, color: Colors.white))
                ],
              )),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Iniciar la animación
  animationController.forward();

  // Remover el SnackBar después de unos segundos

  Future.delayed(Duration(seconds: 5), () {
    if (animationController.isForwardOrCompleted) {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
      });
    }
  });
}

Future<Directory> getUresaxInvoiceDir() async {
  var dir = Directory(path.join(
      Platform.environment['URESAX_INVOICE_STATIC_LOCAL_SERVER_PATH'] ?? 'x',
      'URESAX-INVOICE'));

  print(dir.path);
  return await dir.create(recursive: true);
}

Future<bool> isValidCertFilePath() async {
  try {
    var filePath =
        certFile?.path ?? localStorage.getItem('certFilePath')?.trim();
    var password = certPassword.text;

    certFile = File(filePath ?? '');

    var storePassword = localStorage.getItem('certPassword');

    if (password.isNotEmpty) {
      password = certPassword.text;
    } else {
      password = storePassword ?? '';
    }

    var data = await extraerInfoPfx(path: filePath ?? '', password: password);

    if (data.contains('VIAFIRMA DOMINICANA')) {
      isValid = true;
      currentElectronicNcfOption = 1;
      electronicNcfEnabled = true;
      return true;
    } else {
      return false;
    }
  } catch (e) {
    await LogHandler.printError(e.toString());
    isValid = false;
    currentElectronicNcfOption = 2;
    electronicNcfEnabled = false;
    return false;
  }
}

Future<bool> hasInternet() async {
  try {
    final result = await http
        .get(Uri.parse('https://api.uresax.com'))
        .timeout(Duration(seconds: 5));
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}

showLoader(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(30)),
          content: SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}


String getCertPassword(){
  return  localStorage.getItem('certPassword') ?? '';
}

  String calcularCodigoModificacion(
      DateTime fechaNcfModificado, DateTime fechaEmisionActual) {
    final diferencia = fechaEmisionActual.difference(fechaNcfModificado).inDays;
    return diferencia > 30 ? '1' : '0';
  }

  String getItbisCode({
    required bool esNotaCredito,
    required bool canOverrideTaxes,
    required double gravado18,
    required double gravado16,
    required double originalGravado18,
    required double originalGravado16,
  }) {
    if (esNotaCredito) {
      if (!canOverrideTaxes) {
        return originalGravado18 > 0
            ? '18'
            : originalGravado16 > 0
                ? '16'
                : '';
      } else {
        return originalGravado18 > 0
            ? '0'
            : originalGravado16 > 0
                ? '0'
                : '';
      }
    }
    return gravado18 > 0
        ? '18'
        : gravado16 > 0
            ? '16'
            : '';
  }

  Future<void> enviarDgii({
    required Sale sale,
    required Sale instanceSale,
    required Sale? currentSale,
    required String? currentNcfTypeId,
    required TextEditingController clientName,
    required TextEditingController rncOrId,
    required double xrate,
    required List<FormaDePago> formasDePagos,
    required double totalGravado,
    required double totalGravado18,
    required double totalGravado16,
    required double montoExento,
    required double itbisGravado,
    required double itbisGravado18,
    required double itbisGravado16,
    required double totalRetencionItbis,
    required double totalRetencionIsr,
    required double totalFacturado,
    required DateTime fechaVencimiento,
    required int? currentPaymentMethodId,
    required int? currentPaymentType,
    required String? currentTypeIncomeId,
    required int?  currentOverrideCode,
    required bool canOverrideTaxes

  }) async {
      dynamic estado;
      int? code;
    try {

      String endPointApi = '';

  
      if (enabledEcfProduction) {
        GeneratorEndPoint.envEcfType = EnvEcfType.ecf;
        endPointApi =
            'https://api.uresax.com/produccion/fe/facturaselectronicas/api/ecf';
      } else {
        GeneratorEndPoint.envEcfType = EnvEcfType.testEcf;
        endPointApi =
            'https://api.uresax.com/prueba/fe/facturaselectronicas/api/ecf';
      }
      final cert = certFile;

      String password = getCertPassword();

      EcfType ecfType = EcfType.e31;

      if (currentNcfTypeId == '31') {
        ecfType = EcfType.e31;
      }
      if (currentNcfTypeId == '32') {
        ecfType = EcfType.e32;
      }

      if (currentNcfTypeId == '33') {
        ecfType = EcfType.e33;
      }

      if (currentNcfTypeId == '34') {
        ecfType = EcfType.e34;
      }

      if (currentNcfTypeId == '41') {
        ecfType = EcfType.e41;
      }

      if (currentNcfTypeId == '44') {
        ecfType = EcfType.e44;
      }

      if (currentNcfTypeId == '45') {
        ecfType = EcfType.e45;
      }

      if (currentNcfTypeId == '46') {
        ecfType = EcfType.e46;
      }

      if (currentNcfTypeId == '47') {
        ecfType = EcfType.e47;
      }

      bool esNotaCredito = ecfType == EcfType.e34;

      bool esConsumo = ecfType == EcfType.e32;

      bool esEcf45 = ecfType == EcfType.e45;

      bool esEcf44 = ecfType == EcfType.e44;

      bool esEspecial = esConsumo || esEcf45 || esEcf44;

      if (cert == null) {
        throw 'NO SE HA CONFIGURADO EL CERTIFICADO DIGITAL, NO PUEDE CONTINUAR';
      }

      AuthCertModel authModel =
          await getAuthP12(cert: cert, password: password);

      await LogHandler.printEvent(
          'EL CODIGO BASE 64 ${authModel.certBase64} FUE CREADO');

      final now = DateTime.now().toLocal();
      final dateFormat = DateFormat('dd-MM-yyyy');

      final fechaEmision = dateFormat.format(now);

      String rncEmisor = company?.rncOrId?.trim().replaceAll('-', '') ?? '';

      String rncComprador = rncOrId.text.replaceAll('-', '');
      List<EcfDetailsModel> items = [];

      items = sale.items.map((item) {
        return EcfDetailsModel(
            cantidad: item.quantity?.toStringAsFixed(2) ?? '',
            unidadMedida: '',
            indicadorFacturacion: item.indicadorFacturacion.toString(),
            indicadorBienOServ:
                item is SaleItemService || item is CreditNoteService
                    ? '2'
                    : '1',
            nombreItem: item.serviceName != null
                ? item.serviceName ?? ''
                : item.productName ?? '',
            descripcionItem: '',
            precioUnitario: (item.precio * xrate).toStringAsFixed(2),
            descuentoMonto: '',
            subDescuentos: [],
            impuestosAdicionales: [],
            retencion: esEspecial
                ? null
                : item.retentionTax != 0 || item.retentionIsr != 0
                    ? Retencion(
                        indicadorAgenteRetencionoPercepcion:
                            item.indicadorAgentePercepcion.toString(),
                        montoITBISRetenido: item.retentionTax != null
                            ? (item.retentionTax! * xrate).toStringAsFixed(2)
                            : '',
                        montoISRRetenido: item.retentionIsr != null
                            ? (item.retentionIsr! * xrate).toStringAsFixed(2)
                            : '')
                    : null,
            otraMonedaDetalles: [],
            montoItem:
                item.net != null ? (item.net! * xrate).toStringAsFixed(2) : '');
      }).toList();

      await LogHandler.printEvent(
          'SE INICIO LA CREACION DEL COMPROBANTE ${sale.ncf}');

      formasDePagos = [
        FormaDePago(currentPaymentMethodId.toString(),
            (instanceSale.paid ?? 0).toStringAsFixed(2))
      ];

      EcfModel ecf = EcfModel(
          tipoEcf: ecfType,
          tempDirName: 'temp_7',
          indicadorMontoGravado: totalGravado > 0 ? '0' : '',
          indicadorNotaCredito: esNotaCredito
              ? calcularCodigoModificacion(
                  currentSale!.createdAt!, instanceSale.createdAt!)
              : '',
          numeroComprobante: sale.ncf ?? '',
          numeroComprobanteModificado: currentSale?.ncf ?? '',
          rncOtroContribuyente: '',
          codigoModificacion:
              esNotaCredito ? currentOverrideCode.toString() : '',
          fechaEmision: fechaEmision,
          fechaVencimiento: esNotaCredito || esConsumo
              ? ''
              : fechaVencimiento.format(payload: 'DD-MM-YYYY'),
          fechaEmisionNcfModificado: esNotaCredito
              ?currentSale?.createdAt?.format(payload: 'DD-MM-YYYY') ?? ''
              : '',
          fechaLimitePago: currentPaymentType == 1
              ? ''
              : fechaVencimiento.format(payload: 'DD-MM-YYYY'),
          razonModificacion: '',
          tipoIngreso: currentTypeIncomeId.toString(),
          tipoPago: currentPaymentType.toString(),
          formasDePagos: esNotaCredito ? [] : formasDePagos,
          sucursal: '',
          direccionEmisor: company?.address ?? '',
          municipio: '',
          provincia: '',
          telefonoEmisor1: '',
          telefonoEmisor2: '',
          telefonoEmisor3: '',
          totalPaginas: '',
          rncEmisor: rncEmisor,
          razonSocialEmisor: company?.name ?? '',
          nombreComercial: '',
          correoEmisor: company?.email ?? '',
          website: '',
          actividadEconomica: '',
          codigoVendedor: '',
          informacionAdicionalEmisor: '',
          rncComprador: rncComprador,
          identificadorExtranjero: '',
          razonSocialComprador: clientName.text.trim(),
          nombreComprador: '',
          contactoComprador: '',
          correoComprador: '',
          telefonoAdicional: '',
          direccionComprador: '',
          municipioComprador: '',
          provinciaComprador: '',
          codigoInternoComprador: '',
          fechaEntrega: '',
          fechaOrdenCompra: '',
          numeroOrdenCompra: '',
          numeroFacturaInterna: '',
          numeroPedidoInterno: '',
          zonaVenta: '',
          rutaVenta: '',
          paisDestino: '',
          conductor: '',
          documentoTransporte: '',
          ficha: '',
          placa: '',
          rutaTransporte: '',
          zonaTransporte: '',
          numeroAlbaran: '',
          totalGravado: totalGravado > 0 ? totalGravado.toStringAsFixed(2) : '',
          totalGravado18:
              totalGravado18 > 0 ? totalGravado18.toStringAsFixed(2) : '',
          totalGravado16:
              totalGravado16 > 0 ? totalGravado16.toStringAsFixed(2) : '',
          totalGravadoTasa0: '',
          montoExento: montoExento > 0 ? montoExento.toStringAsFixed(2) : '',
          totalItbis: itbisGravado > 0 ? itbisGravado.toStringAsFixed(2) : '',
          totalItbis18:
              itbisGravado18 > 0 ? itbisGravado18.toStringAsFixed(2) : '',
          totalItbis16:
              itbisGravado16 > 0 ? itbisGravado16.toStringAsFixed(2) : '',
          totalItbisTasa0: '',
          itbis1: getItbisCode(
            esNotaCredito: esNotaCredito,
            canOverrideTaxes: canOverrideTaxes,
            gravado18: itbisGravado18,
            gravado16: 0,
            originalGravado18: currentSale?.tax18 ?? 0,
            originalGravado16: 0,
          ),
          itbis2: getItbisCode(
            esNotaCredito: esNotaCredito,
            canOverrideTaxes: canOverrideTaxes,
            gravado18: 0,
            gravado16: itbisGravado16,
            originalGravado18: 0,
            originalGravado16: currentSale?.tax16 ?? 0,
          ),
          itbis3: '',
          montoTotal:
              totalFacturado > 0 ? totalFacturado.toStringAsFixed(2) : '',
          montoPeriodo: '',
          montoAvancePago: '',
          valorPagar: esEcf45 ? totalFacturado.toStringAsFixed(2) : '',
          tipoMoneda: '',
          tipoCambio: '',
          montoGravadoTotalOtraMoneda: '',
          montoGravadoTotalOtraMoneda1: '',
          montoGravadoTotalOtraMoneda2: '',
          montoGravadoTotalOtraMoneda3: '',
          totalItbisOtraMoneda: '',
          totalItbis1OtraMoneda: '',
          totalItbis2OtraMoneda: '',
          totalItbis3OtraMoneda: '',
          montoExentoOtraMoneda: '',
          montoTotalOtraMoneda: '',
          totalItbisRetencion: esEspecial
              ? ''
              : totalRetencionItbis > 0
                  ? totalRetencionItbis.toStringAsFixed(2)
                  : '0.00',
          totalIsrRetencion: esEspecial
              ? ''
              : totalRetencionIsr > 0
                  ? totalRetencionIsr.toStringAsFixed(2)
                  : '0.00',
          montoImpuestoAdicional: '',
          impuestosAdicionales: [],
          terminoPago: '',
          bancoPago: '',
          paginas: [],
          items: items,
          privateKey: authModel.privateKey,
          certBase64: authModel.certBase64);

      await LogHandler.printEvent(
          'SE INICIO EL PROCESO DE ENVIO A DGII DEL COMPROBANTE ${sale.ncf}');

      await ecf.descargarSemilla();
      await LogHandler.printEvent(
          'SE DESCARGO LA SEMILLA SIN FIRMAR DEL COMPROBANTE ${sale.ncf}');
      await ecf.validarSemilla();

      await LogHandler.printEvent(
          'SE VALIDO LA SEMILLA DEL COMPROBANTE ${sale.ncf}');
      await ecf.firmar();

      await LogHandler.printEvent(
          'SE FIRMO EL XML DEL COMPROBANTE ${sale.ncf}');
    

      final request = http.MultipartRequest('POST', Uri.parse(endPointApi))
        ..headers['accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer ${ecf.token}'
        ..files.add(await http.MultipartFile.fromPath(
          'xml',
          ecf.ecfFile!.path,
          contentType: MediaType('text', 'xml'),
          filename: path.basename(ecf.ecfFile!.path),
        ));

      final response = await request.send();

      code = response.statusCode;

      final body = await response.stream.bytesToString();

      await LogHandler.printEvent(body);

      if (code != 200) {
        throw 'NO FUE POSIBLE ENVIAR LA FACTURA ${sale.ncf} A DGII, CONTACTE CON EL ADMINISTRADOR DEL SISTEMA, ESTADO DE CODIGO [${response.statusCode}]';
      }

  
      print(body);

      estado = jsonDecode(body);

      ecf.trackId = estado['trackId'] ?? '';

      await LogHandler.printEvent(estado.toString());

      if (ecf.trackId != '') {
        await Future.delayed(const Duration(milliseconds: 600));
        estado = await ecf.obtenerEcfEstadoDatos();

        await LogHandler.printEvent(estado.toString());
      }

      DateFormat xdateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
      var fechaFirma = xdateFormat.parse(ecf.fechaHoraFirma);
      sale.dgiiURL = ecf.uriEcf.toString();
      sale.signatureDate = fechaFirma;
      sale.securityCode = ecf.codigoSeguridad;
      sale.ecfXmlFirmado = ecf.ecfSignXml;
      await sale.updateEcfInfo();

      await LogHandler.printEvent(
          'SE ACTUALIZO LA INFORMACION DEL COMPROBANTE ELECTRONICO ${sale.ncf}');

      if (estado != null) {
        var codigo = estado['codigo'] is int
            ? estado['codigo']
            : int.parse(estado['codigo']);

  

        if((sale is CreditNoteAsProduct || sale is SaleProduct) && codigo != 2){
          await sale.updateStock();
          await LogHandler.printEvent(
            'EL STOCK FUE ACTUALIZADO - ${sale.ncf}');
        }
      
        sale.estadoDgii = codigo;

        await sale.updateEcfInfo();

        await LogHandler.printEvent(
            'SE ACTUALIZO EL ESTADO DEL COMPROBANTE ELECTRONICO ${sale.ncf} A DGII, ESTADO: ${sale.estadoDgiiNombre}');
      }
    } catch (e) {

        if(code != 200){
         await sale.delete();
         await LogHandler.printEvent('SE ELIMINO EL COMPROBANTE ${sale.ncf}');
       }


       if(estado != null){
         if(estado['secuenciaUtilizada'] == false){
           await sale.delete();
           await LogHandler.printEvent('SE ELIMINO EL COMPROBANTE ${sale.ncf}');
       }
       }
      rethrow;
    }
  }


  Future<bool?> showConfirm(BuildContext context,
    {String title = 'Confirmacion...'}) async {
  var formKey = GlobalKey<FormState>();
  TextEditingController code = TextEditingController();

  var number = math.Random().nextInt(999999);

  void ok() {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context, true);
    }
  }

  var result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            content: SizedBox(
                width: 400,
                child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(title.toUpperCase(),
                                    style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor))),
                          ]),
                          const SizedBox(height: 15),
                          Text('Escribe el siguiente codigo $number',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: code,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) => int.tryParse(val!) != number
                                ? 'El numero digitado no es correcto'
                                : null,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                             
                                hintText: number
                                    .toString()
                                    .characters
                                    .map((e) => '#')
                                    .toList()
                                    .join()),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).colorScheme.error)),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('CERRAR'))),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: ok,
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('CONFIRMAR')))
                            ],
                          )
                        ],
                      ),
                    ))),
          ));

  return result == true;
}
