USE [Msajag]
GO

/****** Object:  StoredProcedure [dbo].[Stp_TradeDetails]    Script Date: 1/16/2025 6:12:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



Create      Proc [dbo].[Stp_TradeDetails]   
@SaudaDate Varchar(8),  
@ContractNo Varchar(7),  
@Sett_No Varchar(7),  
@Sett_Type Varchar(3),  
@BatchNo Varchar(7),  
@FromParty Varchar(10),  
@ToParty Varchar(10),  
@BrokerSebiRegNo Varchar(12),  
@ExchangeCode Varchar(4),  
@IOrS Varchar(1),  
@Scrip_Cd VarChar(20),  
@GroupCode Varchar(10)  
  
As  
  
If @IOrS = 'S'   
Begin  
 Select ContractNo, Order_No,   
 Trade_No=Pradnya.DBO.ReplaceTradeNo(Trade_No),  
 Sauda_Date, TradeQty, MarketRate, Party_Code, Sett_No, Sett_Type, Scrip_Cd  
                Into #Settlement From settlement I  (nolock)
 Where ContractNo = @ContractNo and  Left(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),8) = @SaudaDate   
 and I.Party_Code Between @FromParty and @ToParty  and Tradeqty <> 0    
 and Sett_No = @Sett_No  and Sett_Type = @Sett_Type  
 And Scrip_Cd = @Scrip_Cd  
   
   
 Select ContractNo, Order_No, Trade_No, Sauda_Date, TradeQty = Sum(TradeQty), MarketRate=Convert(Numeric(18,5),Sum(MarketRate*TradeQty)/Sum(TradeQty)), Party_Code, Sett_No, Sett_Type, Scrip_Cd  
 Into #Settlement_New From #Settlement  
 Group By ContractNo, Order_No, Trade_No, Sauda_Date,Party_Code, Sett_No, Sett_Type, Scrip_Cd  
  
 Select Header , Line, Filler, Sebi,  ContractNo, Order_no, Trade_No, TradeTime,TradeQty ,  
 MarketRate = Right('0000000000' + Substring(Convert(varChar(15),MarketRate),1,CHARINDEX('.',Convert(varChar(15),MarketRate),1)-1),10)+  
 Left(Substring(Convert(varChar(15),MarketRate),CHARINDEX('.',Convert(varChar(15),MarketRate),1)+1,Len(Convert(varChar(15),MarketRate))-1)+'00000',5),Party_code = Right(Space(10) + LTrim(RTrim(Party_Code)), 10)  
 From   
 (  
 -- Select Header = @BatchNo + '13', Line = '00000', Filler=Space(2), Sebi=Left(@BrokerSebiRegNo+'            ',12), ContractNo =  'A23'+Left(Ltrim(Rtrim(ContractNo)) + '             ',13) ,  
    Select Header = @BatchNo + '13', Line = '00000', Filler=Space(2), Sebi=Left(@BrokerSebiRegNo+'            ',12), ContractNo =  'A99'+Left(Ltrim(Rtrim(ContractNo)) + '             ',13) ,  ---Changes for interop---
  Order_no =  Right('0000000000000000' + Ltrim(Rtrim(Order_no)),16) , Trade_No = Right('0000000000000000' +Convert(Varchar, Trade_no), 16) ,   
  TradeTime = Right(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),6),  
  TradeQty = Right('000000000000' + Convert(varChar(12),TradeQty),12)+ '000',  
  MarketRate  =Convert(Numeric(18,5), Round(I.marketrate, Convert(integer,T.marketrate))),I.Party_code  
  From #Settlement_New I, instClient_Tbl T, Client2 C2, client1 c1  
  Where ContractNo = @ContractNo and  Left(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),8) = @SaudaDate   
  and I.Party_Code Between @FromParty and @ToParty  and Tradeqty <> 0  and I.Party_Code = T.PartyCode  
  and Sett_No = @Sett_No  and Sett_Type = @Sett_Type  
  And Scrip_Cd = @Scrip_Cd  
  And C1.Cl_code = c2.Cl_code  
  and C1.Family = (Case When @GroupCode = '' Then C1.Family Else @GroupCode End)  
  And C2.Party_code = I.Party_Code And C2.Dummy6 = 'NSDL' and C2.Dummy7 = '0'   
 ) A  
End  
  
Else  
Begin  
  
 Select ContractNo, Order_No,   
 --Trade_No=Pradnya.DBO.ReplaceTradeNo(Trade_No),
 Trade_No=(CASE WHEN EXCHANGE_IOP='NSE' THEN '23' ELSE '01' END) + Pradnya.DBO.ReplaceTradeNo(Trade_No),   ---changes for interop---
 Sauda_Date, TradeQty, MarketRate, Party_Code, Sett_No, Sett_Type, Scrip_Cd  
                Into #ISettlement From ISettlement_COMBINED  I (NOLOCK)   ---CHANGES FOR INTEROP---
 Where ContractNo = @ContractNo and  Left(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),8) = @SaudaDate   
 and I.Party_Code Between @FromParty and @ToParty  and Tradeqty <> 0    
 and Sett_No = @Sett_No  and Sett_Type = @Sett_Type  
 And Scrip_Cd = @Scrip_Cd   
   
 Select ContractNo, Order_No, Trade_No, Sauda_Date, TradeQty = Sum(TradeQty), MarketRate=Convert(Numeric(18,5),Sum(MarketRate*TradeQty)/Sum(TradeQty)), Party_Code, Sett_No, Sett_Type, Scrip_Cd  
 Into #ISettlement_New From #ISettlement  
 Group By ContractNo, Order_No, Trade_No, Sauda_Date,Party_Code, Sett_No, Sett_Type, Scrip_Cd  
  
 Select Header , Line, Filler, Sebi,  ContractNo, Order_no, Trade_No, TradeTime,TradeQty ,  
 MarketRate = Right('0000000000' + Substring(Convert(varChar(15),MarketRate),1,CHARINDEX('.',Convert(varChar(15),MarketRate),1)-1),10)+  
 Left(Substring(Convert(varChar(15),MarketRate),CHARINDEX('.',Convert(varChar(15),MarketRate),1)+1,Len(Convert(varChar(15),MarketRate))-1)+'00000',5),Party_code = Right(Space(10) + LTrim(RTrim(Party_Code)), 10)  
 From   
 (  
 -- Select Header = @BatchNo + '13', Line = '00000', Filler=Space(2), Sebi=Left(@BrokerSebiRegNo+'            ',12), ContractNo =  'A23'+Left(Ltrim(Rtrim(ContractNo)) + '             ',13) ,  
  Select Header = @BatchNo + '13', Line = '00000', Filler=Space(2), Sebi=Left(@BrokerSebiRegNo+'            ',12), ContractNo =  'A99'+Left(Ltrim(Rtrim(ContractNo)) + '             ',13) ,  ---changes for interop---
  Order_no =  Right('0000000000000000' + Ltrim(Rtrim(Order_no)),16) , Trade_No = Right('0000000000000000' +Convert(Varchar, Trade_no), 16) ,   
  TradeTime = Right(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),6),  
  TradeQty = Right('000000000000' + Convert(varChar(12),TradeQty),12)+ '000',  
  MarketRate  =Convert(Numeric(18,5), Round(I.marketrate, Convert(integer,T.marketrate))),I.Party_code  
  From #ISettlement_New I, instClient_Tbl T, Client2 C2, client1 c1  
  Where ContractNo = @ContractNo and  Left(Replace(Replace(Replace(Convert(Varchar,Sauda_date,120),'-',''),':',''),' ',''),8) = @SaudaDate   
  and I.Party_Code Between @FromParty and @ToParty  and Tradeqty <> 0  and I.Party_Code = T.PartyCode  
  and Sett_No = @Sett_No  and Sett_Type = @Sett_Type  
  And Scrip_Cd = @Scrip_Cd   
  And C1.Cl_code = c2.Cl_code  
  and C1.Family = (Case When @GroupCode = '' Then C1.Family Else @GroupCode End)  
  And C2.Party_code = I.Party_Code And C2.Dummy6 = 'NSDL' and C2.Dummy7 = '0'  
 ) A  
End

GO


