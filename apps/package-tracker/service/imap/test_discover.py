import unittest
from unittest.mock import patch, MagicMock
import discover

class DiscoveryTests(unittest.TestCase):
    def test_authenticated_single_package_notification(self):
        raw = b'From: USPS <alert@tracking.usps.com>\r\nAuthentication-Results: mx.google.com; dmarc=pass header.from=tracking.usps.com\r\nDate: Sat, 26 Sep 2026 08:00:00 -0400\r\nSubject: USPS Expected Delivery - Arriving Soon\r\nContent-Type: text/plain\r\n\r\nUSPS tracking number 9400111899223856928499\nExpected Delivery: September 28, 2026 By 9:00pm'
        p = discover.parse_message(raw)[0]
        self.assertEqual(p['notification']['expected_date'], '2026-09-28')
        self.assertEqual(p['notification']['delivery_window'], 'BY 9:00 PM')
        day_first = raw.replace(b'Expected Delivery: September 28, 2026', b'Expected Delivery On 28 SEP')
        self.assertEqual(discover.parse_message(day_first)[0]['notification']['expected_date'], '2026-09-28')
        self.assertEqual(p['notification']['status'], 'unknown')
        self.assertIn('notification', discover.parse_message(raw.replace(b'header.from=tracking.usps.com', b'header.from=usps.com'))[0])
        self.assertNotIn('notification', discover.parse_message(raw.replace(b'dmarc=pass', b'dmarc=fail'))[0])
        self.assertNotIn('notification', discover.parse_message(raw.replace(b'header.from=tracking.usps.com', b'header.from=attacker.invalid'))[0])
        self.assertNotIn('notification', discover.parse_message(raw+b'\nUSPS tracking number 9400111899223856928400')[0])
        delivered=raw.replace(b'USPS Expected Delivery - Arriving Soon',b'Your package was delivered')
        self.assertEqual(discover.parse_message(delivered)[0]['notification']['status'], 'delivered')
        self.assertNotIn('notification', discover.parse_message(delivered.replace(b'was delivered',b'will be delivered'))[0])

    def test_three_carriers_and_no_fake_domains(self):
        result = discover.extract('https://www.ups.com/track?tracknum=1Z999AA10123456784 https://www.fedex.com/?trknbr=123456789012 https://tools.usps.com/?tLabels=9400111899223856928499 https://fedex.com.bad.example/?trknbr=999999999999')
        self.assertEqual([x['carrier'] for x in result], ['UPS', 'FEDEX', 'USPS'])

    def test_notification_sender_without_contents(self):
        raw = b'From: Example Store <ship@example.invalid>\r\nContent-Type: text/plain\r\n\r\nUPS 1Z999AA10123456784'
        self.assertEqual(discover.parse_message(raw)[0]['sender'], 'Example Store')
        raw = raw.replace(b'Example Store <ship@example.invalid>', b'UPS <alert@ups.com>')
        self.assertEqual(discover.parse_message(raw)[0]['sender'], '')

    def test_readonly_allmail_tls(self):
        client = MagicMock()
        client.list.return_value = ('OK', [b'(\\All \\HasNoChildren) "/" "[Gmail]/All Mail"'])
        client.select.return_value = ('OK', [b'1'])
        with patch.object(discover.imaplib, 'IMAP4_SSL', return_value=client) as create:
            discover.connect('fixture@example.invalid', 'fixture-password')
        self.assertEqual(create.call_args.args, ('imap.gmail.com', 993))
        self.assertEqual(create.call_args.kwargs['ssl_context'].verify_mode, discover.ssl.CERT_REQUIRED)
        client.select.assert_called_once_with('"[Gmail]/All Mail"', readonly=True)

    def test_body_peek_and_success_heartbeat(self):
        client = MagicMock()
        client.uid.side_effect = [('OK', [b'1']), ('OK', [(b'1', b'From: Shop <s@example.invalid>\r\n\r\nUPS 1Z999AA10123456784')])]
        store = MagicMock()
        store.get_password.side_effect = ['fixture@example.invalid', 'fixture-password', 'https://example.invalid/discover', 'fixture-write']
        with patch.object(discover, 'connect', return_value=client), patch.object(discover, 'upload') as upload:
            discover.sync(store)
        self.assertEqual(client.uid.call_args_list[1].args, ('FETCH', b'1', '(BODY.PEEK[])'))
        self.assertEqual(upload.call_args.args[-2:], ([], True))
        self.assertEqual(upload.call_args_list[0].args[-1], False)

if __name__ == '__main__':
    unittest.main()
