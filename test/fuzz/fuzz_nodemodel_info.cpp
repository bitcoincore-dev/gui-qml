// Copyright (c) 2026 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <test/mocks/stubnode.h>

#include <qml/models/nodemodel.h>

#include <QByteArray>
#include <QCoreApplication>
#include <QString>

#include <cstddef>
#include <cstdint>

static int argc = 1;
static char arg0[] = "fuzz_nodemodel_info";
static char* argv[] = {arg0, nullptr};
static QCoreApplication app(argc, argv);

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size)
{
    StubNode node;
    NodeModel model(node, /*backend_ready=*/true);

    // Exercise the node information rendering path with a ready backend.
    (void)model.nodeInformationRows();
    (void)model.defaultProxyAddress();

    const QByteArray raw(reinterpret_cast<const char*>(data), static_cast<int>(size));
    (void)QString::fromUtf8(raw);
    return 0;
}
