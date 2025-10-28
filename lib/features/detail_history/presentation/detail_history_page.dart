import 'package:flutter/material.dart';
import 'package:mobile_pager_flutter/core/domains/orders.dart';
import 'package:mobile_pager_flutter/core/domains/orders_history_dummy.dart';

class DetailHistoryPage extends StatefulWidget 
{
  final String orderId;

  const DetailHistoryPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> 
{
  Orders? _order;

  @override
  void initState() 
  {
    super.initState();
    _loadOrderDetail();
  }

  void _loadOrderDetail() {setState(() {_order = DummyDataService.getDummyOrderDetail(widget.orderId);});}

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _order == null ? const Center(child: Text('Order tidak ditemukan')): SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeaderCard(_order!),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Informasi Order',
              children: [
                _buildInfoRow(
                  'Order ID', 
                  _order!.orderId
                ),
                _buildInfoRow(
                  'Nomor Antrian',
                  _order!.getFormattedQueueNumber()
                ),
                _buildInfoRow(
                  'Status', 
                  _order!.getStatusText()
                ),
                _buildInfoRow(
                  'Tanggal Order',
                  _order!.getFormattedDate()
                ),
                _buildInfoRow(
                  'Waktu Order',
                  _order!.getFormattedTime(_order!.createdAt)
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTimelineCard(_order!),
            const SizedBox(height: 12),
            if (_order!.customer.name != null ||_order!.customer.phone != null)...[
              _buildInfoCard(
                title: 'Informasi Pelanggan',
                children: <Widget>[
                  if (_order!.customer.name != null)...[_buildInfoRow(
                    'Nama', 
                    _order!.customer.name!)
                  ],
                  if (_order!.customer.phone != null)...[_buildInfoRow(
                    'No. Telepon', 
                    _order!.customer.phone!)
                  ],
                  if (_order!.customer.tableNumber != null)...[_buildInfoRow(
                    'Nomor Meja',
                    _order!.customer.tableNumber!)
                  ],
                ],
              ),
              const SizedBox(height: 12)
            ],
            if (_order!.scanLocation != null)...[
              _buildInfoCard(
                title: 'Informasi Lokasi',
                children: <Widget>[
                  _buildInfoRow(
                    'Jarak dari Merchant',
                    _order!.scanLocation!.getFormattedDistance()
                  ),
                  _buildInfoRow(
                      'Waktu Scan',
                      _order!.getFormattedTime(
                        _order!.scanLocation!.timestamp,
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 12)
            ],
            if (_order!.ringing.attempts > 0)...[
              _buildInfoCard(
                title: 'Informasi Panggilan',
                children: <Widget>[
                  _buildInfoRow(
                    'Jumlah Panggilan',
                    '${_order!.ringing.attempts}x',
                  ),
                  if (_order!.ringing.lastRingAt != null)...[
                    _buildInfoRow(
                      'Panggilan Terakhir',
                      _order!.getFormattedTime(
                         _order!.ringing.lastRingAt,
                      ),
                    )
                  ],
                  _buildInfoRow(
                    'Status Panggilan',
                    _order!.ringing.getRingingStatus(),
                  ),
                ],
              ),
              const SizedBox(height: 12)
            ],
            // Notes (if any)
            if (_order!.notes != null && _order!.notes!.isNotEmpty)...[
              _buildInfoCard(
                title: 'Catatan',
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _order!.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12)
            ],
            // Cancel Reason (if cancelled)
            if (_order!.cancelReason != null &&_order!.cancelReason!.isNotEmpty)...[
              _buildInfoCard(
                title: 'Alasan Pembatalan',
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _order!.cancelReason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24)
            ],
            _buildActionButtons(_order!),
            const SizedBox(height: 32),
          ],
        )),
    );
  }

  Widget _buildHeaderCard(Orders order) 
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status),
        boxShadow: <BoxShadow>[
          BoxShadow(
            // Pengganti withOpacity() yang sudah usang menurut flutter
            color: _getStatusColor(order.status).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Icon(
            _getStatusIcon(order.status), 
            size: 64,
            color: Colors.white
          ),
          const SizedBox(height: 16),
          Text(
            order.getStatusText(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.getFormattedQueueNumber(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (order.status == 'ready' && order.expiresAt != null)...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Pengganti withOpacity() yang sudah usang menurut flutter
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget>[
                    const Icon(
                      Icons.timer, 
                      color: Colors.white, 
                      size: 18
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sisa waktu: ${order.getRemainingTime()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children,}) 
  {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            // pengganti withOpacity() yang sudah usang menurut flutter
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) 
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Orders order) 
  {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Timeline Order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            title: 'Order Dibuat',
            time: order.getFormattedTime(order.createdAt),
            isCompleted: true,
            isFirst: true,
          ),
          _buildTimelineItem(
            title: 'Sedang Diproses',
            time: order.getFormattedTime(order.processingAt),
            isCompleted: order.processingAt != null,
          ),
          _buildTimelineItem(
            title: 'Siap Diambil',
            time: order.getFormattedTime(order.readyAt),
            isCompleted: order.readyAt != null,
            subtitle: order.readyAt != null ? 'Waktu tunggu: ${order.getWaitingTime()}' : null,
          ),
          _buildTimelineItem(
            title: 'Sudah Diambil',
            time: order.getFormattedTime(order.pickedUpAt),
            isCompleted: order.pickedUpAt != null,
          ),
          _buildTimelineItem(
            title: 'Selesai',
            time: order.getFormattedTime(order.finishedAt),
            isCompleted: order.finishedAt != null,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isCompleted,
    String? subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) 
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[300],
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted ? const Icon(
                Icons.check, 
                size: 16, 
                color: Colors.white
              ) : null,
            ),
            if (!isLast)...[
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300]
              )
            ],
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey[600]
                  ),
                ),
                if (subtitle != null)...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Orders order) 
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          if (order.status == 'ready')...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _confirmPickup(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Konfirmasi Sudah Diambil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          if (order.canBeCancelled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _cancelOrder(order),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Batalkan Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
          if (order.status == 'finished') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _orderAgain(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                ),
                child: const Text(
                  'Pesan Lagi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) 
  {
    switch (status) 
    {
      case 'waiting':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.lightGreen;
      case 'finished':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) 
  {
    switch (status) 
    {
      case 'waiting':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.restaurant;
      case 'ready':
        return Icons.notifications_active;
      case 'picked_up':
        return Icons.check_circle;
      case 'finished':
        return Icons.done_all;
      case 'expired':
        return Icons.timer_off;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _confirmPickup(Orders order) async 
  {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah order sudah diambil?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Sudah Diambil'),
          ),
        ],
      ),
    );

    if (confirm == true) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order berhasil dikonfirmasi (DUMMY MODE)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _cancelOrder(Orders order) async 
  {
    final TextEditingController reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Apakah kamu yakin ingin membatalkan order ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan pembatalan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order berhasil dibatalkan (DUMMY MODE)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _orderAgain(Orders order) async 
  {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur pesan lagi akan segera hadir!')));}
}