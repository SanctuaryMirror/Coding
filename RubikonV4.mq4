//+------------------------------------------------------------------+
//|                                                    RubikonV4.mq4 |
//|                                               Przemek Ciesielski |
//|                                             https://www.mql5.com |
//|                 © 2019 Przemysław Ciesielski All Rights Reserved |
//+------------------------------------------------------------------+
#property copyright "Przemek Ciesielski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input int reserve = 5; // Dodatkowa ilosc punktow miedzy otwarci]ami.
input int recoveryzone = 35; // Reco-Zone [MUSI BYC] maxymalna wartosc roznicy miedzy sell buy
input double lotsize = 0.01; //wprowadz wielkosc pierwszej pozycji
input double multi = 2; // multiplier pozycji [1.4, max agresywny na 2]
extern int Slippage = 10;
extern bool TradeType = 0; // 1 dla agresywnego, 0 dla pasywnego;


int Slip;
double UsePoint;
double CalcPoint;
double CalcSlippage;
double Points;
double y;
   int check;
         double BuyTakeProfit;
   double SellTakeProfit;
      double buyprice;
   double sellprice;
   

double Rounding(double value)
{
double x=value;
for (double i=1;i<100;i++)
{
Print ("Rounding petla for , i=", i," value=",x);
if (x<i/100 || x>(i/100)+0.01)
{
continue;
}

if (x>i/100 && x<(i/100)+0.01)
{
x=(i/100)+0.01;
Print ("For Value=",x);
return (x);
break;
}
else
{
continue;
}
}
Print ("Value=",x);
return (x);
}
double CandlePrice(string Currency)
   {
      int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
      if(CalcDigits == 2 || CalcDigits == 3) Points = 100;
      if (CalcDigits == 4 || CalcDigits == 5) Points= 10000;
      return(Points);
   }
   
int Tasks(int closingcontrol=0)
{
         for (int i=0; i<=OrdersTotal();i++)
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         if (OrderSymbol()== Symbol())
        {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
            closingcontrol++;    
            }
         else if (OrderType() == OP_SELLLIMIT || OP_BUYLIMIT)
         {
            } 
     return (closingcontrol);
}
      
   bool Way(bool x=0)
   {
      for (int i=0; i<=OrdersTotal(); i++)
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      if (OrderSymbol()== Symbol())
      {
         if (OrderType() == OP_BUY)
         x=1;
         else if (OrderType() == OP_SELL)
         x=0;
      }
      return(x);
   }
   
 int Total(int x=0)
   {
      for( int i=0; i<=OrdersTotal();i++)
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
         if (OrderSymbol()== Symbol())
            {
            if (OrderType() == OP_BUY ||OrderType()==  OP_SELL ||OrderType() == OP_BUYSTOP ||OrderType()==  OP_SELLSTOP||OrderType()==  OP_BUYLIMIT || OrderType()==  OP_SELLLIMIT)
            x++;
            }
      return(x);
   }
   
   int TotalAll(int x=0)
   {
      for( int i=0; i<=OrdersTotal();i++)
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
            {
            if (OrderType() == OP_BUY ||OrderType()==  OP_SELL ||OrderType() == OP_BUYSTOP ||OrderType()==  OP_SELLSTOP||OrderType()==  OP_BUYLIMIT || OrderType()==  OP_SELLLIMIT)
            x++;
            }
      return(x);
   }

   int OrderCheck(int x=0)
   {
      for( int i=0; i<=OrdersTotal();i++)
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
         /*if (OrderSymbol()== Symbol())*/
         {
            if (OrderType() == OP_BUY ||OrderType()==  OP_SELL)
            x++;
         else if (OrderType() == OP_BUYSTOP ||OrderType()==  OP_SELLSTOP||OrderType()==  OP_BUYLIMIT || OrderType()==  OP_SELLLIMIT)
         continue;
         }
         return(x);
   }
   
   double PipPoint(string Currency)
   {
      int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
      if(CalcDigits == 2 || CalcDigits == 3) CalcPoint = 0.01;
      else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
      return(CalcPoint);
   }
   
   int GetSlippage(string Currency, int SlippagePips)
   {
      int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
      if(CalcDigits == 2 || CalcDigits == 3) CalcSlippage = SlippagePips;
      else if(CalcDigits == 4 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
      return(CalcSlippage);
   }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   UsePoint = PipPoint(Symbol());
   Slip = GetSlippage(Symbol(), Slippage);
   int opentasks = OrderCheck();
   bool Way=Way();
   int closingcontrol = Tasks();
   int iTotal=Total();
   int iTotalAll=TotalAll();
   double actualpriceBUY=Bid;
   double actualpriceSELL=Ask;
   double dSumLotBuy=0;
   double dSumLotSELL=0;
   double MyHigh;
   double MyLow;
   double MyHigh1;
   double MyLow1;
   double CandlePoints=CandlePrice(Symbol());
   RefreshRates();
   double HighFractal;
   double LowFractal;
   double MyHighCalc;
   double MyLowCalc;
   int candleshift;
   int control;

   
   
   if (iTotal==iTotalAll)
   {   
   if (opentasks>0)
   {
     for   (int i=0;i<=OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
      if(OrderSymbol()== Symbol())
      if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP)
      {
         dSumLotBuy+= OrderLots();
      }
      else if(OrderType()== OP_SELL || OrderType() == OP_SELLSTOP)
      {
      dSumLotSELL+= OrderLots();
      }
   }
      for (int i=0; i<=OrdersTotal();i++)
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      if (OrderSymbol()== Symbol())
      {
         if (OrderType()==OP_BUY||OrderType()==OP_BUYSTOP)
         {
         buyprice= OrderOpenPrice();
         BuyTakeProfit=OrderTakeProfit();
         SellTakeProfit=OrderStopLoss();
         }
         else if (OrderType()== OP_SELL||OrderType()==OP_SELLSTOP)
         {
         sellprice=OrderOpenPrice();
         BuyTakeProfit=OrderStopLoss();
         SellTakeProfit=OrderTakeProfit();
         }
      }
      if (opentasks == 1)
      {
      if(dSumLotBuy==dSumLotSELL)
      {
      check=2;
      }
      else
      {
      check=3;
      }  
      }
      if (opentasks >=2)
      {
      check=3;
      }
      Print("Check=",check,"  cena BUY=", buyprice," cena SELL=",sellprice,"  TP=",BuyTakeProfit,"  SL=",SellTakeProfit,"  Loty BUY=",dSumLotBuy,"  Loty SELL=",dSumLotSELL);
    }
   if (iTotal<=0)
   {
   if (check<1)
   {
         for (int i=0;i<100;i++)
         {
         HighFractal=iFractals(NULL,0,MODE_UPPER,i);
         LowFractal=iFractals(NULL,0,MODE_LOWER,i);
            if (control<=0)
            {
               if (HighFractal>0)
               {
               //Print ("Krok 0 HIGH");
               MyHigh=HighFractal;
               HighFractal=NULL;
               control=1;
               continue;
               }
               if (LowFractal>0)
               {
               //Print ("Krok 0 LOW");
               MyLow=LowFractal;
               LowFractal=NULL;
               control=2;
               continue;
               }
            }
            if (control>0 && control<2)
            {
               if (HighFractal>MyHigh)
               {
               //Print ("Krok 1 HIGH");
               MyHigh=HighFractal;
               HighFractal=NULL;
               continue;
               }
               if (LowFractal>0)
               {
               //Print ("Krok 1 LOW");
               MyLow=LowFractal;
               LowFractal=NULL;
               control=3;
               continue;
               }
            }
            if (control>1 && control<3)
            {
               if (LowFractal<MyLow && LowFractal>0)
               {
               //Print ("Krok 2 LOW");
               MyLow=LowFractal;
               LowFractal=NULL;
               continue;
               }
               if (HighFractal>0)
               {
               //Print ("Krok 2 HIGH");
               MyHigh=HighFractal;
               HighFractal=NULL;
               control=4;
               continue;
               }
            }
            if (control>2 && control<4)
            {
               if (LowFractal<MyLow && LowFractal>0)
               {
               //Print ("Krok 3 LOW");
               MyLow=LowFractal;
               LowFractal=NULL;
               continue;
               }
               if (HighFractal>0)
               {
               //Print ("Krok 3 HIGH");
               MyHigh1=HighFractal;
               control=5;
               continue;
               }
            }
            if (control>4 && control<6)
            {
               if (HighFractal>MyHigh1)
               {
               //Print ("Krok 5 HIGH");
               MyHigh1=HighFractal;
               HighFractal=NULL;
               continue;
               }
               if (LowFractal>0)
               {
               //Print ("Krok 5 LOW");
               MyLow1=LowFractal;
               LowFractal=NULL;
               control=7;
               continue;
               }
            }
            if (control>3 && control<5)
            {
               if (HighFractal>MyHigh)
               {
               //Print ("Krok 4 HIGH");
               MyHigh=HighFractal;
               HighFractal=NULL;
               continue;
               }
               if (LowFractal>0)
               {
               //Print ("Krok 4 LOW");
               MyLow1=LowFractal;
               LowFractal=NULL;
               control=6;
               continue;
               }
            }
            if (control>5 && control<7)
            {
            if (LowFractal<MyLow1 && LowFractal>0)
               {
               //Print ("Krok 6 LOW");
               MyLow1=LowFractal;
               LowFractal=NULL;
               continue;
               }
               if (HighFractal>0)
               {
               //Print ("Krok 6 HIGH");
               MyHigh1=HighFractal;
               HighFractal=NULL;
               control=8;
               continue;
               }
            }
            if (control>6 && control<8)
            {
            if (LowFractal<MyLow1 && LowFractal>0)
               {
               //Print ("Krok 7 LOW");
               MyLow1=LowFractal;
               LowFractal=NULL;
               continue;
               }
               if (HighFractal>0)
               {
               //Print ("Krok 7 HIGH");
               check=1;
               break;
               }
            }
            if (control>7 && control<9)
            {
            if (HighFractal>MyHigh1)
               {
               //Print ("Krok 8 HIGH");
               MyHigh1=HighFractal;
               HighFractal=NULL;
               continue;
               }
               if (LowFractal>0)
               {
               //Print ("Krok 8 LOW");
               check=1;
               break;
               }
            }
   }
   RefreshRates();        
   }
   if (check>0 && check<2)
   {
   Print ("MyHigh=",MyHigh," MyLow=",MyLow," MyHigh1=",MyHigh1," MyLow1=",MyLow1," Control=", control);
   if (MyHigh-MyLow>=(MyHigh1-MyLow)*7/10 && MyHigh-MyLow<=(MyHigh1-MyLow)*13/10)
      {
      if (MyHigh1-MyLow>=(MyHigh1-MyLow1)*7/10 && MyHigh1-MyLow<=(MyHigh1-MyLow1)*13/10)
         {
         if (MyHigh-MyLow>=(MyHigh1-MyLow1)*7/10 && MyHigh-MyLow<=(MyHigh1-MyLow1)*13/10)
            {
            if (MyHigh>MyHigh1)
            {
            MyHighCalc=MyHigh;
            }
            if (MyHigh<=MyHigh1)
            {
            MyHighCalc=MyHigh1;
            }
            if (MyLow>MyLow1)
            {
            MyLowCalc=MyLow;
            }
            if (MyLow<=MyLow1)
            {
            MyLowCalc=MyLow1;
            }
         }
         else
         {
         /*Print ("Angle is to big! :<");*/
         check=0;
         MyHigh=NULL;
         MyHigh1=NULL;
         MyLow=NULL;
         MyLow1=NULL;
         control=0;
         HighFractal=NULL;
         LowFractal=NULL;
         RefreshRates();
         }
      }
      else
      {
      /*Print ("Angle is to big! :<");*/
      check=0;
      MyHigh=NULL;
      MyHigh1=NULL;
      MyLow=NULL;
      MyLow1=NULL;
      control=0;
      HighFractal=NULL;
      LowFractal=NULL;
      RefreshRates();
      }
   }
   else
   {
   /*Print ("Angle is to big! :<");*/
   check=0;
   MyHigh=NULL;
   MyHigh1=NULL;
   MyLow=NULL;
   MyLow1=NULL;
   control=0;
   HighFractal=NULL;
   LowFractal=NULL;
   RefreshRates();
   }
   /*Print ("WE have ", (MyHighCalc-MyLowCalc)*CandlePoints," points of difference :)", MyHighCalc,"   ",MyLowCalc);*/
   RefreshRates();        
   }
   RefreshRates();
   }
   if (recoveryzone>= (MyHighCalc-MyLowCalc)*CandlePoints)
   {
   if (check<2 &&  check>0)
   {
   Print ("Jestem w sekcji otwierania pierwszych dwoch pozycji");
   buyprice=MyHighCalc+(reserve*UsePoint);
   sellprice=MyLowCalc-(reserve*UsePoint);
   for (int i=1;i<10000;i++)
   {
   if (i*multi >= i+((buyprice-sellprice)*CandlePoints))
   {
   Print ("wielkosc TP to ",i," Pipsów");
   BuyTakeProfit=buyprice+(i*UsePoint)+((i*1/multi)*UsePoint);
   SellTakeProfit=sellprice-(i*UsePoint)-((i*1/multi)*UsePoint);
   break;
   }
   else continue;
   }
   if (buyprice>Ask && sellprice<Bid)
   {
   //BuyTakeProfit=buyprice+((buyprice-sellprice)*2);
   //SellTakeProfit=sellprice-((buyprice-sellprice)*2);
   Print ("BUYOPEN=",buyprice," SELLOPEN=",sellprice," BUYTP=", BuyTakeProfit," SELLTP=",SellTakeProfit);
   int ticket=OrderSend(Symbol(), OP_SELLSTOP,lotsize, sellprice,Slip, BuyTakeProfit,SellTakeProfit, "check 1", 5, 0, clrNONE);
                           if(ticket<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=2;
                           RefreshRates();
                           }                        
  int ticket1=OrderSend(Symbol(), OP_BUYSTOP,lotsize, buyprice,Slip, SellTakeProfit,BuyTakeProfit, "check 1", 5, 0, clrNONE);
                           if(ticket1<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=2;
                           RefreshRates();
                           }
   check=2;
   RefreshRates();
  }
  else
  {
  check=0;
         MyHigh=NULL;
         MyHigh1=NULL;
         MyLow=NULL;
         MyLow1=NULL;
         control=0;
         HighFractal=NULL;
         LowFractal=NULL;
         RefreshRates();
  }
  }
  }
  if (opentasks>0 && opentasks<2)
  {
  //Print ("jestem w sekcji usuwania pozycji i dodawania drugiej", check);
  if (check>1 && check<3)
  {
  //Print ("Jestem w Petli for do usuwania");
  for (int i=0; i<OrdersTotal();i++)
  {
  if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
  {
         if (OrderSymbol()== Symbol())
         {
         if (OrderType()==OP_BUYSTOP)
         {
         buyprice=OrderOpenPrice();
         bool x=OrderDelete(OrderTicket());
                  if (OrderDelete(OrderTicket())==false)
                  Print("OrderDelete failed with error #",GetLastError());
                  else if (OrderDelete(OrderTicket())==true)
                  Print ("OrderDelete succeed.");
         }
         if (OrderType()==OP_SELLSTOP)
         {
         sellprice=OrderOpenPrice();
         bool x=OrderDelete(OrderTicket());
                  if (OrderDelete(OrderTicket())==false)
                  Print("OrderDelete failed with error #",GetLastError());
                  else if (OrderDelete(OrderTicket())==true)
                  Print ("OrderDelete succeed.");
         }
         }
         }
         }
         Print ("cena otwarcia buy=",buyprice," cena otwarcia sell=",sellprice," BUYTP=", BuyTakeProfit," SELLTP=",SellTakeProfit," lotsize=",lotsize*multi);
  if (TradeType>0)
  {
  if (Way<1)
  {       
  int ticket1=OrderSend(Symbol(), OP_BUYSTOP,lotsize*multi, buyprice,Slip, SellTakeProfit,BuyTakeProfit, "check 2", 5, 0, clrNONE);
                           if(ticket1<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=3;
                           RefreshRates();
                           }
  }
  RefreshRates();
  if (Way>0)
  {
  int ticket1=OrderSend(Symbol(), OP_SELLSTOP,lotsize*multi, sellprice,Slip, BuyTakeProfit,SellTakeProfit, "check 2", 5, 0, clrNONE);
                           if(ticket1<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=3;
                           RefreshRates();
                           }
  }
  RefreshRates();
  }
  if (TradeType<1)
  {
  if (Way<1)
  {
  double x=(((BuyTakeProfit-sellprice)*dSumLotSELL*100)+(BuyTakeProfit-buyprice))/(BuyTakeProfit-buyprice)/100;
  /*for (int i=1;i<=100;i++)
  {
  y=(((BuyTakeProfit-sellprice)+(BuyTakeProfit-buyprice))*dSumLotSELL)/(BuyTakeProfit-buyprice);
   if (y>i/100 && y<=(i/100)+0.01)
   {
   y=(i/100)+0.01;
   Print ("wynik petli for y=", y);
   break;
   }
   else continue;
  }*/
  int ticket1=OrderSend(Symbol(), OP_BUYSTOP,Rounding(x), buyprice,Slip, SellTakeProfit,BuyTakeProfit, "check 2", 5, 0, clrNONE);
                           if(ticket1<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=3;
                           RefreshRates();
                           }
  }
  RefreshRates();
  if (Way>0)
  {
  double x=(((BuyTakeProfit-sellprice)*dSumLotBuy*100)+(BuyTakeProfit-buyprice))/(BuyTakeProfit-buyprice)/100;
/*for (int i=1;i<=100;i++)
  {
  y=(((BuyTakeProfit-sellprice)+(BuyTakeProfit-buyprice))*dSumLotBuy)/(BuyTakeProfit-buyprice);
   if (y>i/100 && y<=(i/100)+0.01)
   {
   y=(i/100)+0.01;
   Print ("wynik petli for y=", y);
   break;
   }
   else continue;
  }*/
  int ticket1=OrderSend(Symbol(), OP_SELLSTOP,Rounding(x), sellprice,Slip, BuyTakeProfit,SellTakeProfit, "check 2", 5, 0, clrNONE);
                           if(ticket1<0)
                           {
                           Print("OrderSend failed with error #",GetLastError());
                           }
                           else
                           {
                           Print("OrderSend placed successfully");
                           check=3;
                           RefreshRates();
                           }
  }
  RefreshRates();
  }
  }
  }
  if (check>2 && opentasks >= iTotal)
   {
      Print ("jestem w sekcji kolejnych ntych pozycji ", check, " ", Way);
      if (TradeType>0)
      {
               if (Way<1)
               {
               UsePoint=PipPoint(Symbol());
               Slip=GetSlippage(Symbol(), Slippage);
                  { 
                     int ticket=OrderSend(Symbol(), OP_BUYSTOP,(dSumLotSELL*multi)-dSumLotBuy , buyprice, 10, SellTakeProfit, BuyTakeProfit, "check 3", 5, 0, clrNONE);
                        if(ticket<0)
                        {
                        Print("OrderSend failed with error #",GetLastError());
                        return;
                        }
                        else
                        {
                        Print("OrderSend placed successfully");
                        return;
                        }
                  }
                  RefreshRates();
               }      
               if (Way>0)
                  {
                  UsePoint = PipPoint(Symbol());
                  Slip = GetSlippage(Symbol(),Slippage);
                     {
                     int ticket=OrderSend(Symbol(), OP_SELLSTOP, (dSumLotBuy*multi)-dSumLotSELL, sellprice, 10, BuyTakeProfit, SellTakeProfit, "check 3", 5, 0, clrNONE);
                        if(ticket<0)
                        {
                        Print("OrderSend failed with error #",GetLastError());
                        return;
                        }
                        else
                        {
                        Print("OrderSend placed successfully");
                        return;
                        }
                        RefreshRates();
                     }               
                  }
                  check=3;
                  RefreshRates();
                  }
   if (TradeType<1)
      {
               if (Way<1)
               {
               double x=(((BuyTakeProfit-sellprice)*dSumLotSELL*100)+(BuyTakeProfit-buyprice))/(BuyTakeProfit-buyprice)/100;
  /*for (int i=1;i<=100;i++)
  {
  y=(((BuyTakeProfit-sellprice)+(BuyTakeProfit-buyprice))*dSumLotSELL)/(BuyTakeProfit-buyprice);
   if (y>i/100 && y<=(i/100)+0.01)
   {
   y=(i/100)+0.01;
   Print ("wynik petli for y=", y);
   break;
   }
   else continue;
  }*/
               UsePoint=PipPoint(Symbol());
               Slip=GetSlippage(Symbol(), Slippage);
                  { 
                     int ticket=OrderSend(Symbol(), OP_BUYSTOP,Rounding(x)-dSumLotBuy,buyprice, 10, SellTakeProfit, BuyTakeProfit, "check 3", 5, 0, clrNONE);
                        if(ticket<0)
                        {
                        Print("OrderSend failed with error #",GetLastError());
                        return;
                        }
                        else
                        {
                        Print("OrderSend placed successfully");
                        return;
                        }
                  }
                  RefreshRates();
               }      
               if (Way>0)
                  {
                  double x=(((BuyTakeProfit-sellprice)*dSumLotBuy*100)+(BuyTakeProfit-buyprice))/(BuyTakeProfit-buyprice)/100;
                   /*  for (int i=1;i<=100;i++)
  {
  y=(((BuyTakeProfit-sellprice)+(BuyTakeProfit-buyprice))*dSumLotBuy)/(BuyTakeProfit-buyprice);
   if (y>i/100 && y<=(i/100)+0.01)
   {
   y=(i/100)+0.01;
   Print ("wynik petli for y=", y);
   break;
   }
   else continue;
  }*/
                  UsePoint = PipPoint(Symbol());
                  Slip = GetSlippage(Symbol(),Slippage);
                     {
                     int ticket=OrderSend(Symbol(), OP_SELLSTOP, Rounding(x)-dSumLotSELL, sellprice, 10, BuyTakeProfit, SellTakeProfit, "check 3", 5, 0, clrNONE);
                        if(ticket<0)
                        {
                        Print("OrderSend failed with error #",GetLastError());
                        return;
                        }
                        else
                        {
                        Print("OrderSend placed successfully");
                        return;
                        }
                        RefreshRates();
                     }               
                  }
                  check=3;
                  RefreshRates();
                  }
                  }
   if (opentasks<iTotal && check>0)
   {
   if (Ask >= BuyTakeProfit)
   {
   Slip = GetSlippage(Symbol(), Slippage);
     for (int i=OrdersTotal()-1; i >= 0; i--)
     {
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
     if (OrderSymbol()== Symbol())
     if (OrderType()== OP_BUYSTOP ||OrderType()==  OP_SELLSTOP ||OrderType()==  OP_BUYLIMIT ||OrderType()==  OP_SELLLIMIT)
     {
     bool x=OrderDelete(OrderTicket());
     if (OrderDelete(OrderTicket())==false)
     Print("OrderDelete failed with error #",GetLastError());
     else if (OrderDelete(OrderTicket())==true)
     Print ("OrderDelete succeed.");
     }
     if (OrderType()== OP_BUY)
     bool z=OrderClose(OrderTicket(),OrderLots(), Bid, Slippage*Slip, clrNONE);
     if (OrderType()==OP_SELL)
     bool y=OrderClose(OrderTicket(), OrderLots(), Ask, Slippage*Slip, clrNONE);
     }
     check=0;
     buyprice=NULL;
     sellprice=NULL;
     BuyTakeProfit=NULL;
     SellTakeProfit=NULL;
     dSumLotBuy=NULL;
     dSumLotSELL=NULL;
     MyHigh=NULL;
     MyLow=NULL;
     for (int i=0;i<10;i++)
     {
     }
     RefreshRates();
     }
   
     if ( Bid <= SellTakeProfit)
     {
     Slip = GetSlippage(Symbol(), Slippage);
     for (int i=OrdersTotal()-1; i >= 0; i--)
     {
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
     if (OrderSymbol()== Symbol())
     if (OrderType()== OP_BUYSTOP ||OrderType()==  OP_SELLSTOP ||OrderType()==  OP_BUYLIMIT ||OrderType()==  OP_SELLLIMIT)
     {
     bool x=OrderDelete(OrderTicket());
     if (OrderDelete(OrderTicket())==false)
     Print("OrderDelete failed with error #",GetLastError());
     else if (OrderDelete(OrderTicket())==true)
     Print ("OrderDelete succeed.");
     } 
     if (OrderType()== OP_BUY)
     bool z=OrderClose(OrderTicket(),OrderLots(), Bid, Slippage*Slip, clrNONE);
     if (OrderType()==OP_SELL)
     bool y=OrderClose(OrderTicket(), OrderLots(), Ask, Slippage*Slip, clrNONE);
     }
     check=0;
     buyprice=NULL;
     sellprice=NULL;
     BuyTakeProfit=NULL;
     SellTakeProfit=NULL;
     dSumLotBuy=NULL;
     dSumLotSELL=NULL;
     MyHigh=NULL;
     MyLow=NULL;
     for (int i=0;i<10;i++)
     {
     }
     RefreshRates();
     }               
   }
  }
  }
//+------------------------------------------------------------------+
