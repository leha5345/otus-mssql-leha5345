use [DAX2009_1]
DECLARE @INVOICEID nvarchar(30), @VOUCHER  nvarchar(30), @ACCOUNTNUM nvarchar(20), @FACTUREID nvarchar(30), @ITEMID nvarchar(20), @INVENTTRANSID nvarchar(30), @DATAAREAID nvarchar(4), @inventSerialId nvarchar(40);
--SET DATAAREAID = 'SZ';
--SET @ACCOUNTNUM = '�000968'
;WITH PURH_CTE
	AS (
	select 
		VENDINVOICEJOUR.PURCHID,
		VENDINVOICEJOUR.ORDERACCOUNT,
		VENDINVOICEJOUR.INVOICEID,
		VENDINVOICEJOUR.INVOICEDATE,
		VendInvoiceTrans.ITEMID,
		VendInvoiceTrans.INVENTDIMID,
		InventDim.PurchReqLineId,
		INVENTDIM.inventSerialId
	from VendInvoiceTrans
	JOIN InventTrans		ON VendInvoiceTrans.ITEMID		= InventTrans.ITEMID
	JOIN InventDim			ON InventTrans.INVENTDIMID = InventDim.INVENTDIMID
	JOIN VENDINVOICEJOUR	ON VendInvoiceTrans.PURCHID		= VENDINVOICEJOUR.PURCHID
		AND VendInvoiceTrans.INVOICEID		= VENDINVOICEJOUR.INVOICEID
		AND VendInvoiceTrans.INVOICEDATE	= VENDINVOICEJOUR.INVOICEDATE
		AND VendInvoiceTrans.DATAAREAID		= VENDINVOICEJOUR.DATAAREAID
	WHERE VENDINVOICEJOUR.DATAAREAID = 'SZ'
		AND VENDINVOICEJOUR.ORDERACCOUNT = '�000968'
		AND InventTrans.TransType = 3 -- ����� �� �������
		AND InventTrans.STATUSRECEIPT = 1
		AND InventTrans.DIRECTION = 1
		),

	PurchReq_CTE
	AS (			
	select 
		PurchReqTable.PurchReqId,
		PurchReqLine.LineId,
		PurchReqLine.PurchReqState,
		CHARINDEX('RZ',PurchReqTable.ATTENTION) as Position,
		PurchReqTable.Attention	
	from PurchReqTable
	JOIN PurchReqLine		ON PurchReqLine.PURCHREQID = PurchReqTable.PURCHREQID
	WHERE PurchReqLine.PurchReqState IN (3,5) --3 ��������, 5 ���������
		AND PurchReqTable.Attention <> ''
		),

	Sales_CTE
	AS (
	select 
--		SALESTABLE.SALESID,
		CUSTTABLE.ACCOUNTNUM,
		CUSTTABLE.NAME,
		CUSTTABLE.NAMEALIAS,
		TenderTable.TradingCode, -- KT,			 
		SZ_TenderShippingMap.TradingCode as Tr, -- �������,
		CUSTINVOICEJOUR.INVOICEDATE,
		CustInvoiceJour.INVOICEDATEMP,
		WMSOrderTrans.itemId,
		InventDim.inventSerialId, -- ��������_�����,
		InventDim.PURCHREQLINEID, -- �����_������,
		INVENTTRANS.QTY
	from SALESTABLE
	JOIN SZ_TenderShippingMap	ON SALESTABLE.SALESID		= SZ_TenderShippingMap.SalesOrTransferRef
	LEFT JOIN TENDERTABLE		ON SalesTable.TENDERTABLEID = TENDERTABLE.TENDERTABLEID
	JOIN WMSPickingRoute		ON SalesTable.SALESID		= WMSPickingRoute.TRANSREFID
	JOIN WMSOrderTrans			ON WMSPickingRoute.PICKINGROUTEID = WMSOrderTrans.ROUTEID
	JOIN INVENTTABLE			ON WMSOrderTrans.itemId = INVENTTABLE.ITEMID
	JOIN InventTrans			ON WMSOrderTrans.INVENTTRANSID = InventTrans.INVENTTRANSID
	JOIN InventDim				ON InventTrans.INVENTDIMID = InventDim.INVENTDIMID
	JOIN CustInvoiceJour		ON CustInvoiceJour.SALESID	= SALESTABLE.SALESID
	JOIN CUSTTABLE				ON CustInvoiceJour.ORDERACCOUNT = CUSTTABLE.ACCOUNTNUM
	WHERE SalesTable.DATAAREAID = 'SZ'
		AND WMSPickingRoute.DATAAREAID = 'SZ'
		AND CustInvoiceJour.DATAAREAID = SALESTABLE.DATAAREAID
		AND CustInvoiceJour.InvoiceDate > N'2022-01-01T00:00:00.000'
		AND InventTrans.DATAAREAID = WMSOrderTrans.DATAAREAID
		AND SZ_TenderShippingMap.DATAAREAID = SalesTable.DATAAREAID
		AND WMSOrderTrans.expeditionStatus = 10 -- ���������
		AND WMSOrderTrans.DATAAREAID = WMSPickingRoute.DATAAREAID
		AND WMSPickingRoute.TRANSTYPE = 0 -- ����� �� �������	 
		AND SalesTable.RContractSubjectId = '������� ������������' -- ������� ��������
		AND SalesTable.RContractCode = '�-������'
		AND InventTrans.TransType = 0 -- ����� �� �������
		AND InventTrans.StatusIssue = 1 -- ������ = �������
		AND InventTrans.Direction = 2 -- ������/���� = ������
		AND SalesTable.SZ_InventTransfer = 0 -- ����������� ���
		),

	SalesMP_CTE
	AS (
	select 
--		SALESTABLE.SALESID,
		CUSTTABLE.ACCOUNTNUM,
		CUSTTABLE.NAME,
		CUSTTABLE.NAMEALIAS,
		TenderTable.TradingCode, -- KT,			 
		SZ_TenderShippingMap.TradingCode as Tr, -- �������,
		CUSTINVOICEJOUR.INVOICEDATE,
		CustInvoiceJour.INVOICEDATEMP,
		WMSOrderTrans.itemId,
		InventDim.inventSerialId, -- ��������_�����,
		InventDim.PurchReqLineId, -- �����_������,
		INVENTTRANS.QTY
	from SALESTABLE
	JOIN SZ_TenderShippingMap	ON SALESTABLE.SALESID		= SZ_TenderShippingMap.SalesOrTransferRef
	LEFT JOIN TENDERTABLE		ON SalesTable.TENDERTABLEID = TENDERTABLE.TENDERTABLEID
	JOIN WMSPickingRoute		ON SalesTable.SALESID		= WMSPickingRoute.TRANSREFID
	JOIN WMSOrderTrans			ON WMSPickingRoute.PICKINGROUTEID = WMSOrderTrans.ROUTEID
	JOIN INVENTTABLE			ON WMSOrderTrans.itemId = INVENTTABLE.ITEMID
	JOIN InventTrans			ON WMSOrderTrans.INVENTTRANSID = InventTrans.INVENTTRANSID
	JOIN InventDim				ON InventTrans.INVENTDIMID = InventDim.INVENTDIMID
	JOIN CustInvoiceJour		ON CustInvoiceJour.SALESID	= SALESTABLE.SALESID
	JOIN CUSTTABLE				ON SalesTable.SZ_CustAccountTransfer = CUSTTABLE.ACCOUNTNUM
	WHERE SalesTable.DATAAREAID = 'SZ'
		AND WMSPickingRoute.DATAAREAID = 'SZ'
		AND CustInvoiceJour.DATAAREAID = SALESTABLE.DATAAREAID
		AND CustInvoiceJour.InvoiceDate > N'2022-01-01T00:00:00.000'
		AND InventTrans.DATAAREAID = WMSOrderTrans.DATAAREAID
		AND SZ_TenderShippingMap.DATAAREAID = SalesTable.DATAAREAID
		AND WMSOrderTrans.expeditionStatus = 10 -- ���������
		AND WMSOrderTrans.DATAAREAID = WMSPickingRoute.DATAAREAID
		AND WMSPickingRoute.TRANSTYPE = 0 -- ����� �� �������	 
		AND SalesTable.RContractSubjectId = '������� ������������' -- ������� ��������
		AND SalesTable.RContractCode = '�-������'
		AND InventTrans.TransType = 0 -- ����� �� �������
		AND InventTrans.StatusIssue = 1 -- ������ = �������
		AND InventTrans.Direction = 2 -- ������/���� = ������
		AND SalesTable.SZ_InventTransfer = 1 -- ����������� ��
		)
select DISTINCT
	Sales_CTE.ACCOUNTNUM as ���_�������,
	Sales_CTE.NAMEALIAS as �������_������������_�������,
--	PurchReq_CTE.Position,
	SUBSTRING(PurchReq_CTE.ATTENTION,CHARINDEX('RZ',PurchReq_CTE.ATTENTION),11) as RZ,
--	PurchReq_CTE.ATTENTION,
	Sales_CTE.Tr as ��_�������,
	Sales_CTE.TRADINGCODE as �����_�������, 
--	Sales_CTE.INVOICEDATE,
	CONVERT(date,Sales_CTE.INVOICEDATE,103) as ����_���������,
	Sales_CTE.ITEMID as ���_������,
	INVENTTABLE.NAMEALIAS as ������������_������,
	Sales_CTE.INVENTSERIALID,
	(CAST(Sales_CTE.QTY AS NUMERIC(20,0))*-1) as ���_��
	
from PurchReq_CTE
JOIN Sales_CTE		ON Sales_CTE.PurchReqLineId		= PurchReq_CTE.LineId
JOIN INVENTTABLE	ON Sales_CTE.ITEMID				= INVENTTABLE.ITEMID
WHERE PurchReq_CTE.Position <> '0'
--	AND Sales_CTE.INVENTSERIALID <> '0'
UNION
select 
	SalesMP_CTE.ACCOUNTNUM as ���_�������,
	SalesMP_CTE.NAMEALIAS as �������_������������_�������,
--	PurchReq_CTE.Position,
	SUBSTRING(PurchReq_CTE.ATTENTION,CHARINDEX('RZ',PurchReq_CTE.ATTENTION),11) as RZ,
--	PurchReq_CTE.ATTENTION,
	SalesMP_CTE.Tr as ��_�������,
	SalesMP_CTE.TRADINGCODE as �����_�������, 
--	SalesMP_CTE.INVOICEDATE,
	CONVERT(date,SalesMP_CTE.INVOICEDATE,103) as ����_���������,
	SalesMP_CTE.ITEMID as ���_������,
	INVENTTABLE.NAMEALIAS as ������������_������,
	SalesMP_CTE.INVENTSERIALID,
	(CAST(SalesMP_CTE.QTY AS NUMERIC(20,0))*-1) as ���_��
	
from PurchReq_CTE
JOIN SalesMP_CTE		ON SalesMP_CTE.PurchReqLineId		= PurchReq_CTE.LineId
JOIN INVENTTABLE	ON SalesMP_CTE.ITEMID				= INVENTTABLE.ITEMID
WHERE PurchReq_CTE.Position <> '0'
--	AND SalesMP_CTE.INVENTSERIALID <> '0'
