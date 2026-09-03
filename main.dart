import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String api = 'http://10.0.2.2:5200/api';

void main() => runApp(const FreshCycleApp());

class FreshCycleApp extends StatelessWidget {
  const FreshCycleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FreshCycle Laundry',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xff173d32)),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState()=>_HomePageState();
}

class _HomePageState extends State<HomePage> {
  List services=[]; List orders=[]; bool loading=true; String message='';
  final stages=['Requested','Pickup scheduled','Picked up','Processing','Ready','Out for delivery','Delivered'];

  @override void initState(){super.initState();load();}
  Future<void> load() async {
    try {
      final a=await http.get(Uri.parse('$api/services'));
      final b=await http.get(Uri.parse('$api/orders'));
      if(a.statusCode==200) services=jsonDecode(a.body);
      if(b.statusCode==200) orders=jsonDecode(b.body);
    } catch(e) {}
    if(mounted)setState(()=>loading=false);
  }

  Future<void> book() async {
    try {
      final id=services.isNotEmpty?services.first['id']:null;
      final r=await http.post(Uri.parse('$api/orders'),
        headers:{'Content-Type':'application/json'},
        body:jsonEncode({'customerName':'Demo Customer','pickupDate':DateTime.now().add(const Duration(days:1)).toIso8601String(),
          'pickupWindow':'10:00 - 13:00','serviceId':id,'notes':'Laundry pickup'}));
      if(r.statusCode>=200&&r.statusCode<300){setState(()=>message='Pickup request created.');await load();}
      else setState(()=>message='Could not create order.');
    } catch(e){setState(()=>message='Backend not reachable.');}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(titleRow(),actions:[TextButton(onPressed:(){},child:const Text('Sign in'))]),
    body:loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(
      onRefresh:load,child:ListView(padding:const EdgeInsets.all(20),children:[
      hero(), sectionTitle('Services and pricing'),
      ...serviceCards(), sectionTitle('How an order moves'),
      timeline(), sectionTitle('Recent orders'),
      ...orderCards(), const SizedBox(height:30),
      const Center(child:Text('© FreshCycle Laundry',style:TextStyle(color:Colors.grey)))
    ])));

  Widget titleRow()=>Row(children:[Container(width:42,height:42,alignment:Alignment.center,
    decoration:BoxDecoration(color:const Color(0xff173d32),borderRadius:BorderRadius.circular(12)),
    child:const Text('FC',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),
    const SizedBox(width:10),const Column(crossAxisAlignment:CrossAxisAlignment.start,
    children:[Text('FreshCycle Laundry',style:TextStyle(fontWeight:FontWeight.bold)),
    Text('Laundry management system',style:TextStyle(fontSize:12,color:Colors.grey))])]);

  Widget hero()=>Container(margin:const EdgeInsets.only(bottom:25),padding:const EdgeInsets.all(24),
    decoration:BoxDecoration(color:const Color(0xffdcebe3),borderRadius:BorderRadius.circular(22)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('FRESH • CLEAN • SIMPLE',style:TextStyle(fontSize:12,letterSpacing:2,fontWeight:FontWeight.bold)),
      const SizedBox(height:10),const Text('Pickup, cleaning and delivery — organised end to end.',
      style:TextStyle(fontSize:34,fontWeight:FontWeight.bold,height:1.05)),
      const SizedBox(height:12),const Text('Book a collection slot, track your laundry and keep your orders in one place.',
      style:TextStyle(fontSize:16,color:Colors.black54)),
      const SizedBox(height:18),FilledButton(onPressed:book,child:const Text('Book a pickup')),
      if(message.isNotEmpty)Padding(padding:const EdgeInsets.only(top:10),child:Text(message))
    ]));

  Widget sectionTitle(String x)=>Padding(padding:const EdgeInsets.only(top:18,bottom:12),
    child:Text(x,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)));

  List<Widget> serviceCards()=>services.isEmpty?[
    card('Wash & Fold','Everyday clothing, washed and folded.',12),
    card('Dry Cleaning','Professional care for delicate garments.',18),
    card('Ironing','Crisp, ready-to-wear laundry.',8)
  ]:services.map((x)=>card(x['name'],x['description'],x['price'])).toList();

  Widget card(String name,String desc,dynamic price)=>Card(child:Padding(padding:const EdgeInsets.all(18),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(name,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
      const SizedBox(height:7),Text(desc,style:const TextStyle(color:Colors.black54)),
      const SizedBox(height:12),Text('£${double.tryParse(price.toString())?.toStringAsFixed(2)??'0.00'}',
      style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))
    ])));

  Widget timeline()=>Column(children:stages.asMap().entries.map((e)=>Card(
    child:ListTile(leading:CircleAvatar(child:Text('${e.key+1}')),title:Text(e.value)))).toList());

  List<Widget> orderCards()=>orders.map((x)=>Card(child:ListTile(
    leading:Text('#${x['id']}',style:const TextStyle(fontWeight:FontWeight.bold)),
    title:Text(x['customerName']??'Customer'),trailing:Text(x['status']??'Requested')))).toList();
}
